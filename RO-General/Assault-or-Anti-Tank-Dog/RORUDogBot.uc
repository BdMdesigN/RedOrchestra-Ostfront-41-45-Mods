// ====================================================================
//  Class:  RORUDogBot
//  Parent: xBot
//   Dynamit:
//  <A custom Dog Bot Controller>
// ====================================================================
//
//------------------------------------------------------------------------------

class RORUDogBot extends xBot;

var Shepard Sentry;
var bool bLostContactToPL;

//var	int			DesiredRole;	// Role the bot wants to be
//var	int			CurrentRole;	// Role the bot is currently
var	int			PrimaryWeapon;		// Stores the weapon selections
var	int			SecondaryWeapon;
var	int			GrenadeWeapon;
var float 		LastFriendlyFireYellTime;
var float		NearMult, FarMult;		// multipliers for startle collision distances
var ROVehicle AvoidVehicle;			// vehicle we are currently avoiding
var actor       DodgeActor;       	    // Actor bot is presently trying to avoid colliding with
var actor       LastDodgeActor;         // Recent DodgeActor we temporarily don't care about
var float       LastDodgeTime;          // Last time you routed around somebody
var float 		RepeatDodgeFrequency;	// how much time must pass before you can dodge the same person again
var float		CachedMoveTimer;		// hack to save move timer

// Bot support - helps allow telling bots to attack/defend specific objectives
const attackID = 0;				// The messageID for the attack command in the voice pack
const defendID = 1;             // The messageID for the defend command in the voice pack

function NotifyIneffectiveAttack(optional Pawn Other)
{
}

// Using VehicleCharging As a base for this code
state TacticalVehicleMove extends MoveToGoalWithEnemy
{
	ignores SeePlayer, HearNoise;

	function Timer()
	{
		Target = Enemy;
		TimedFireWeaponAtEnemy();
		CheckVehicleRoute();
	}

	function FindDestination()
	{
		local actor HitActor;
		local vector HitLocation, HitNormal, Cross;

		if ( MoveTarget == None )
		{
			Destination = Pawn.Location;
			return;
		}
		Destination = Pawn.Location + 5000 * Normal(Pawn.Location - MoveTarget.Location);
		HitActor = Trace(HitLocation, HitNormal, Destination, Pawn.Location, false);

		if ( HitActor == None )
			return;

		Cross = Normal((Destination - Pawn.Location) cross vect(0,0,1));
		Destination = Destination + 1000 * Cross;
		HitActor = Trace(HitLocation, HitNormal, Destination, Pawn.Location, false);
		if ( HitActor == None )
			return;

		Destination = Destination - 2000 * Cross;
		HitActor = Trace(HitLocation, HitNormal, Destination, Pawn.Location, false);
		if ( HitActor == None )
			return;

		Destination = Destination + 1000 * Cross - 3000 * Normal(Pawn.Location - MoveTarget.Location);
	}

	function EnemyNotVisible()
	{
		WhatToDoNext(15);
	}

Begin:
	if (Pawn.Physics == PHYS_Falling)
	{
		Focus = Enemy;
		Destination = Enemy.Location;
		WaitForLanding();
	}
	if ( Enemy == None )
		WhatToDoNext(16);
	if ( Pawn.Physics == PHYS_Flying )
	{
		if ( VSize(Enemy.Location - Pawn.Location) < 1200 )
		{
			FindDestination();
			MoveTo(Destination, None, false);
			if ( Enemy == None )
				WhatToDoNext(91);
		}
		MoveTarget = Enemy;
	}
	else if ( Squad.SquadObjective != none )
	{
      if ( !( VSize(Squad.SquadObjective.location - Pawn.Location) < 6000  && FindBestPathToward(Enemy, false,true) )
      ||  !FindBestPathToward(Squad.SquadObjective, false,true) )
   	{
		if (Pawn.HasWeapon())
			GotoState('RangedAttack');
		else
			WanderOrCamp(true);
	}
   }
Moving:
	FireWeaponAt(Enemy);
	MoveToward(MoveTarget,FaceActor(1),,ShouldStrafeTo(MoveTarget));
	WhatToDoNext(17);
	if ( bSoaking )
		SoakStop("STUCK IN TacticalVehicleMove!");
}

// Overriding some Bot movement states to cause the bots to sprint. This is a bit of a
// hack right now.

// Stop sprinting when we are doing a tactical move
state TacticalMove
{
ignores /*SeePlayer,*/ HearNoise;

	function BeginState()
	{
		Super.BeginState();
		ROPawn(Pawn).SetSprinting(False);
	}

}

// Sprint when we are moving to a goal
state MoveToGoal
{
	function bool CheckPathToGoalAround(Pawn P)
	{
		if ( (MoveTarget == None) || (Bot(P.Controller) == None) || !SameTeamAs(P.Controller) )
			return false;

		if ( Bot(P.Controller).Squad.ClearPathFor(self) )
			return true;
		return false;
	}

	function Timer()
	{
		SetCombatTimer();
		ROPawn(Pawn).SetSprinting(True);
		enable('NotifyBump');
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);

		if( !Pawn.bWantsToCrouch )
			ROPawn(Pawn).SetSprinting(True);
	}
}

// Sprint when we are moving to a goal
//Dynamit: basically a duplicate MoteToGoal state modified for our needs.
//
state DogMoveToGoal
{
	function bool CheckPathToGoalAround(Pawn P) //Dynamit we wont be using paths, are we?
	{
		if ( (MoveTarget == None) || (Bot(P.Controller) == None) || !SameTeamAs(P.Controller) )
			return false;

		if ( Bot(P.Controller).Squad.ClearPathFor(self) )
			return true;
		return false;
	}

	function Timer()
	{
		SetCombatTimer();
		ROPawn(Pawn).SetSprinting(True);
		enable('NotifyBump'); //Dynamit: if we hit something, e.g. player?
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self); //we wont be using cautious advance.

		if( !Pawn.bWantsToCrouch )
			ROPawn(Pawn).SetSprinting(True);
	}
}

// Sprint when we are moving to a goal
//Dynait: modifying this
state Roaming
{
	ignores EnemyNotVisible;

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')) );
	}

	function Timer()
	{
		super.Timer();
		if( Vehicle(Pawn) != none )
			CheckVehicleRoute();
	}

	function BeginState()
	{
		super.BeginState();
		SetTimer(0.05, true);
		if(ROPawn(Pawn) != none)
		ROPawn(Pawn).SetSprinting(True);
	}

Begin:
	//SwitchToBestWeapon(); //Dog isnt switchin weapons.
	WaitForLanding();
	if ( Pawn.bCanPickupInventory && (InventorySpot(MoveTarget) != None) && (Squad.PriorityObjective(self) == 0) && (Vehicle(Pawn) == None) )
	{
		MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(self,5);
		if ( (Pickup(MoveTarget) != None) && !Pickup(MoveTarget).ReadyToPickup(0) )
		{
			CampTime = MoveTarget.LatentFloat;
			GoalString = "Short wait for inventory "$MoveTarget;
			GotoState('RestFormation','ShortWait');
		}
	}                     //disable strafin!
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
DoneRoaming:
	WaitForLanding();
	WhatToDoNext(12);
	if ( bSoaking )
		SoakStop("STUCK IN ROAMING!");
}

// Sprint when we are moving to a goal
state Fallback
{
//	function bool FireWeaponAt(Actor A)
//	{
//		if ( (A == Enemy) && (Pawn.Weapon != None) && (Pawn.Weapon.AIRating < 0.5)
//			&& (Level.TimeSeconds - Pawn.SpawnTime < DeathMatch(Level.Game).SpawnProtectionTime)
//			&& (Squad.PriorityObjective(self) == 0)
//			&& (InventorySpot(Routegoal) != None) )
//		{
//			// don't fire if still spawn protected, and no good weapon
//			return false;
//		}
//		return Global.FireWeaponAt(A);
//	}

//	function Timer()
//	{
//		super.Timer();
//		if( Vehicle(Pawn) != None )
//			CheckVehicleRoute();
//	}


 //  function NotifyIneffectiveAttack(optional Pawn Other)
//   {
//	  if(ROVehicle(Pawn) != none)
//		 WhatToDoNext(54);
//   }

	function bool IsRetreating() // we dont need to be facing the enemy!
	{
		return ( (Pawn.Acceleration Dot (Pawn.Location - Enemy.Location)) > 0 );
	}

	event bool NotifyBump(actor Other)
	{
		local Pawn P;
		local Vehicle V;

		if ( (Vehicle(Other) != None) && (Vehicle(Pawn) == None) )
		{
			if ( Other == RouteGoal || (Vehicle(RouteGoal) != None && Other == Vehicle(RouteGoal).GetVehicleBase()) )
			{
				V = Vehicle(RouteGoal).FindEntryVehicle(Pawn);  //Dynamit: bot tries to go in vehicle!
				if ( V != None )
				{
					V.UsedBy(Pawn);
					if (Vehicle(Pawn) != None)
					{
						Squad.BotEnteredVehicle(self);
						WhatToDoNext(54);
					}
				}
				return true;
			}
		}

		Disable('NotifyBump');
		if ( MoveTarget == Other )
		{
			if ( MoveTarget == Enemy && Pawn.HasWeapon() )
			{
				TimedFireWeaponAtEnemy();  //Dynamit: Order to advance on enemy! And attack!
				DoRangedAttackOn(Enemy);
			}
			return false;
		}

		P = Pawn(Other);
		if ( (P == None) || (P.Controller == None) )
			return false;
		if ( !SameTeamAs(P.Controller) && (MoveTarget == RouteCache[0]) && (RouteCache[1] != None) && P.ReachedDestination(MoveTarget) )
		{
			MoveTimer = VSize(RouteCache[1].Location - Pawn.Location)/(Pawn.GroundSpeed * Pawn.DesiredSpeed) + 1;
			MoveTarget = RouteCache[1];
		}
		Squad.SetEnemy(self,P);
		if ( Enemy == Other )
		{
			Focus = Enemy;   //Dynamit: Check distance and advance enemy.
			TimedFireWeaponAtEnemy(); //Attack
		}
		if ( CheckPathToGoalAround(P) )   //This is what we need in order to avoid lon routes
			return false;

		AdjustAround(P);
		return false;
	}

   function ReceiveProjectileWarning(Projectile proj) //Bot is being shot at!!!
   {
	  super.ReceiveProjectileWarning(proj);

	  if(Vehicle(Pawn) != none)
		 WhatToDoNext(54);
   }

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget != None)
					&& ((MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup')) );
	}

	function EnemyNotVisible()
	{
		if ( Squad.FindNewEnemyFor(self,false) || (Enemy == None) )
			WhatToDoNext(13);
		else
		{
			enable('SeePlayer');
			disable('EnemyNotVisible');
		}
	}

	function EnemyChanged(bool bNewEnemyVisible)  //Dog functionality goes here.
	{
		bEnemyAcquired = false;
		SetEnemyInfo(bNewEnemyVisible);
		if ( bNewEnemyVisible )
		{
		//	disable('SeePlayer');
			enable('EnemyNotVisible');
		}
	}

	function BeginState()
	{
		SetTimer(0.05, true);
		super.BeginState();
	}

Begin:
	WaitForLanding();
	if( ROPawn(Pawn) != none )
		ROPawn(Pawn).SetSprinting(True);

Moving:      //DYnamit: remove unneeded stuff
	//if ( Pawn.bCanPickupInventory && (InventorySpot(MoveTarget) != None) && (Vehicle(Pawn) == None) )
		//MoveTarget = InventorySpot(MoveTarget).GetMoveTargetFor(self,0);
	MoveToward(MoveTarget,FaceActor(1),GetDesiredOffset(),ShouldStrafeTo(MoveTarget));
	if( ROPawn(Pawn) != none )
	    ROPawn(Pawn).SetSprinting(True);
	WhatToDoNext(14);
	if ( bSoaking )
		SoakStop("STUCK IN FALLBACK!");
	goalstring = goalstring$" STUCK IN FALLBACK!";
}

// Added code to get bots using ironsights in a rudimentary fashion
//Dynamit: COMPLETELY REMOVE THIS or Modify it for our needs (close range melee attack)
state RangedAttack
{
ignores HearNoise, Bump;

   function NotifyIneffectiveAttack(optional Pawn Other)
   {
	  if(VehicleWeaponPawn(Pawn) != none && VehicleWeaponPawn(Pawn).VehicleBase != none && VehicleWeaponPawn(Pawn).VehicleBase.Controller != none)
	  {
		 ROBot(VehicleWeaponPawn(Pawn).VehicleBase.Controller).NotifyIneffectiveAttack(Other);
		 return;
	  }

//      if(ROPawn(Other) == none)
//      {
		 Target = Enemy;
		 GoalString = "Position Myself";
		 GotoState('TacticalVehicleMove');
//      }
   }

	function BeginState()
	{
	   local byte i;
	   local ROVehicle V;
	   local Pawn P;

		StopStartTime = Level.TimeSeconds;
		bHasFired = false;
		if ( (Pawn.Physics != PHYS_Flying) || (Pawn.MinFlySpeed == 0) )
		Pawn.Acceleration = vect(0,0,0); //stop

		if ( (Pawn.Weapon != None) && Pawn.Weapon.FocusOnLeader(false) )
			Target = Focus;
		else if ( Target == None )
			Target = Enemy;
		if ( Target == None )
			log(GetHumanReadableName()$" no target in ranged attack");

		if ( ROVehicle(Pawn) != None )
		{
			Vehicle(Pawn).Steering = 0;
			Vehicle(Pawn).Throttle = 0;
			Vehicle(Pawn).Rise = 0;

		 V = ROVehicle(Pawn);
		 P = V.Driver;
	  }
	  else if(ROVehicleWeaponPawn(Pawn) != none)
	  {
		 V = ROVehicleWeaponPawn(Pawn).VehicleBase;
		 P = ROVehicleWeaponPawn(Pawn).Driver;
	  }

	  if(V != none)
	  {
		   for(i=0; i < V.WeaponPawns.Length; i++)
		   {
		      if(V.WeaponPawns[i] == none)
		          break;
		      if(ROVehicleWeaponPawn(V.WeaponPawns[i]).Driver == none)
		      {
			   if(V.WeaponPawns[i].isA('ROTankCannonPawn'))
			   {
				  V.KDriverLeave(true);
				  V.WeaponPawns[i].KDriverEnter(P);
				  break;
			   }

               if(ROPawn(Enemy) != none && V.bIsApc && ROVehicleWeaponPawn(V.WeaponPawns[i]).bIsMountedTankMG)
               {
                  V.KDriverLeave(true);
                  V.WeaponPawns[i].KDriverEnter(P);
                  break;
			}
		   }
		}
		}
		// Cause bots to use thier ironsights when they do this
		if( Pawn.Weapon != none &&  ROProjectileWeapon(Pawn.Weapon) != none )
		{
			ROProjectileWeapon(Pawn.Weapon).ZoomIn(false);
		}
	}

   function EndState()
   {
	   local VehicleWeaponPawn V;
	   local Pawn P;

	   V = VehicleWeaponPawn(Pawn);

	  if(V != none)
	  {
		 P = V.Driver;
		 if( V.VehicleBase.Driver == none)
		 {
			V.KDriverLeave(true);
			V.VehicleBase.KDriverEnter(P);
		 }
	  }
   }

Begin:
	bHasFired = false;
	if ( (Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon )
		SwitchToBestWeapon();
	GoalString = GoalString@"Ranged attack";
	Focus = Target;
	Sleep(0.0);
	if ( Target == None )
		WhatToDoNext(335);

	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	if ( NeedToTurn(Target.Location) )
	{
		Focus = Target;
		FinishRotation();
   }
	bHasFired = true;
	if ( Target == Enemy )
		TimedFireWeaponAtEnemy();
	else
		FireWeaponAt(Target);
	Sleep(0.1);
	if ( ((Pawn.Weapon != None) && Pawn.Weapon.bMeleeWeapon) || (Target == None) || ((Target != Enemy) && (GameObjective(Target) == None) && (Enemy != None) && EnemyVisible()) )
		WhatToDoNext(35);
	if ( Enemy != None )
		CheckIfShouldCrouch(Pawn.Location,Enemy.Location, 1);
	Focus = Target;
	Sleep(FMax(Pawn.RangedAttackTime(),0.2 + (0.5 + 0.5 * FRand()) * 0.4 * (7 - Skill)));
	WhatToDoNext(36);
	if ( bSoaking )
		SoakStop("STUCK IN RANGEDATTACK!");
}

//-----------------------------------------------------------------------------
// Empty
//-----------------------------------------------------------------------------

function bool CanComboMoving() {return false;}
function bool CanCombo() {return false;}
function bool AutoTaunt() {return false;}
function bool CanImpactJump() {return false;}
function bool CanUseTranslocator() {return false;}
function ImpactJump() {}

function Possess(Pawn aPawn)
{
	Super.Possess(aPawn);
	if ( ROPawn(aPawn) != None )
		ROPawn(aPawn).Setup(PawnSetupRecord);
}

function SendMessage(PlayerReplicationInfo Recipient, name MessageType, byte MessageID, float Wait, name BroadcastType)
{
	local vector myLoc;
	// limit frequency of same message
	if ( (MessageType == OldMessageType) && (MessageID == OldMessageID)
		&& (Level.TimeSeconds - OldMessageTime < Wait) )
		return;

	if ( Level.Game.bGameEnded || Level.Game.bWaitingToStartMatch )
		return;

	OldMessageID = MessageID;
	OldMessageType = MessageType;

	if (Pawn == none)
		myLoc = location;
	else
		myLoc = Pawn.location;
	SendVoiceMessage(PlayerReplicationInfo, Recipient, MessageType, MessageID, BroadcastType, Pawn, myLoc);

}

// Recieve a command from a player. Overriden to allow specific attack/defend commands for objectives
function BotVoiceMessage(name messagetype, byte MessageID, Controller Sender)
{
	if ( !Level.Game.bTeamGame || (Sender.PlayerReplicationInfo.Team != PlayerReplicationInfo.Team) )
		return;

	// Vehicle bot commands. This is hacked in for now. Its a good start to see how you can control bots
	// in vehicles though
	if ( messagetype == 'VEH_ORDERS' )
	{
			switch (MessageID)	// First 3 bits define double click move
			{
				case 10:
					GetOutOfVehicle();
					break;
				case 2:
					messagetype = 'ORDER';
					MessageID = 2;
					break;
				//default:
				case 1:
					messagetype = 'ORDER';
					MessageID = 4;
					break;
				case 3:
					messagetype = 'ORDER';
					MessageID = 4;
					break;
				case 4:
					messagetype = 'ORDER';
					MessageID = 4;
					break;
				case 5:
					messagetype = 'ORDER';
					MessageID = 4;
					break;

				//TODO: Add support for 'goto' command?
			}
	}
	else if ( messagetype == 'VEH_ALERTS' )
	{
	   if (MessageID == 8)
	   {
	       GetOutOfVehicle();
	   }
	}



	if ( messagetype == 'ORDER' )
		SetOrders(OrderNames[messageID], Sender);
	else if ( messagetype == 'ATTACK' )
		SetOrders(OrderNames[attackID], Sender);
	else if ( messagetype == 'DEFEND' )
		SetOrders(OrderNames[defendID], Sender);
}

// Subclassed to allow for setting the correct team or role specific model in ROTeamgame - Ramm
//function ChangeCharacter(string newCharacter, optional string inClass)
//{
//	if( inClass != "")
//	{
//		SetPawnClass(inClass, newCharacter);
//	}
//	else
//	{
//		SetPawnClass(string(PawnClass), newCharacter);
//	}

//	UpdateURL("Character", newCharacter, true);
	//SaveConfig();
//}

// Overriden to allow for setting the correct RO-specific pawn class
//function SetPawnClass(string inClass, string inCharacter)
//{
//	local class<ROPawn> pClass;

//	pClass = class<ROPawn>(DynamicLoadObject(inClass, class'Class'));
//	if (pClass != None)
//		PawnClass = pClass;

//	PawnSetupRecord = class'xUtil'.static.FindPlayerRecord(inCharacter);
//	PlayerReplicationInfo.SetCharacterName(PawnSetupRecord.DefaultName);
//}

//-----------------------------------------------------------------------------
// GetRoleInfo - Returns the current RORoleInfo
//-----------------------------------------------------------------------------

//function RORoleInfo GetRoleInfo()
//{
//	return ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo;
//}

//-----------------------------------------------------------------------------
// GetPrimaryWeapon
//-----------------------------------------------------------------------------
//Dynamit: removed all inventory related stuff. Dog has no inventory.
//IN the future: May add ability for dog to transport some sort of ammunition from player to player.


// Overriden to support our respawn system
state Dead
{
ignores SeePlayer, EnemyNotVisible, HearNoise, ReceiveWarning, NotifyLanded, NotifyPhysicsVolumeChange,
		NotifyHeadVolumeChange,NotifyLanded,NotifyHitWall,NotifyBump;

Begin:
	if ( Level.Game.bGameEnded )
		GotoState('GameEnded');
	Sleep(0.2);
TryAgain:
	if ( UnrealMPGameInfo(Level.Game) == None )
		destroy();
}

// Overriden to support getting rid of the pawn when a bot is destroyed, otherwise
// You are left with a skin ninja pawn that just stands there
simulated event Destroyed()
{
	local Vehicle DrivenVehicle;
	local Pawn Driver;

	if ( Pawn != None )
	{
		// If its a vehicle, just destroy the driver, otherwise do the normal.
		DrivenVehicle = Vehicle(Pawn);
		if( DrivenVehicle != None )
		{
			Driver = DrivenVehicle.Driver;
			DrivenVehicle.KDriverLeave(true); // Force the driver out of the car
			if ( Driver != None )
			{
				Driver.Health = 0;
				Driver.Died( self, class'Suicided', Driver.Location );
			}
		}
		else
		{
			Pawn.Health = 0;
			Pawn.Died( self, class'Suicided', Pawn.Location );
		}
	}

	super.Destroyed();
}

/* MayDodgeToMoveTarget()
called when starting MoveToGoal(), based on DodgeToGoalPct
Know have CurrentPath, with end lower than start
*/
// Overriden because we dont subclass UnrealPawn
event MayDodgeToMoveTarget()
{
	return;
}

// Overriden because we dont subclass UnrealPawn so we need to remove double click stuff
function bool TryToDuck(vector duckDir, bool bReversed)
{
	local vector HitLocation, HitNormal, Extent, Start;
	local actor HitActor;
	local bool bSuccess, bDuckLeft, bWallHit, bChangeStrafe;
	local float MinDist,Dist;

	if ( Vehicle(Pawn) != None )
		return Pawn.Dodge(DCLICK_None);
	if ( Pawn.bStationary )
		return false;
	if ( Stopped() && (Pawn.MaxRotation == 0) )
		GotoState('TacticalMove');
	else if ( FRand() < 0.6 )
		bChangeStrafe = IsStrafing();


	if ( (Skill < 3) || Pawn.PhysicsVolume.bWaterVolume || (Pawn.Physics == PHYS_Falling)
		|| (Pawn.PhysicsVolume.Gravity.Z > Pawn.PhysicsVolume.Default.Gravity.Z) )
		return false;
	if ( Pawn.bIsCrouched || Pawn.bWantsToCrouch || (Pawn.Physics != PHYS_Walking) )
		return false;

	duckDir.Z = 0;
	duckDir *= 335;
	bDuckLeft = bReversed;
	Extent = Pawn.GetCollisionExtent();
	Start = Pawn.Location + vect(0,0,25);
	HitActor = Trace(HitLocation, HitNormal, Start + duckDir, Start, false, Extent);

	MinDist = 150;
	Dist = VSize(HitLocation - Pawn.Location);
	if ( (HitActor == None) || ( Dist > 150) )
	{
		if ( HitActor == None )
			HitLocation = Start + duckDir;

		HitActor = Trace(HitLocation, HitNormal, HitLocation - MAXSTEPHEIGHT * vect(0,0,2.5), HitLocation, false, Extent);
		bSuccess = ( (HitActor != None) && (HitNormal.Z >= 0.7) );
	}
	else
	{
		bWallHit = Pawn.bCanWallDodge && (Skill + 2*Jumpiness > 5);
		MinDist = 30 + MinDist - Dist;
	}

	if ( !bSuccess )
	{
		bDuckLeft = !bDuckLeft;
		duckDir *= -1;
		HitActor = Trace(HitLocation, HitNormal, Start + duckDir, Start, false, Extent);
		bSuccess = ( (HitActor == None) || (VSize(HitLocation - Pawn.Location) > MinDist) );
		if ( bSuccess )
		{
			if ( HitActor == None )
				HitLocation = Start + duckDir;

			HitActor = Trace(HitLocation, HitNormal, HitLocation - MAXSTEPHEIGHT * vect(0,0,2.5), HitLocation, false, Extent);
			bSuccess = ( (HitActor != None) && (HitNormal.Z >= 0.7) );
		}
	}
	if ( !bSuccess )
	{
		if ( bChangeStrafe )
			ChangeStrafe();
		return false;
	}

	if ( Pawn.bCanWallDodge && (Skill + 2*Jumpiness > 3 + 3*FRand()) )
		bNotifyFallingHitWall = true;

	bInDodgeMove = true;
	DodgeLandZ = Pawn.Location.Z;
	return true;
}

function SendVoiceMessage(PlayerReplicationInfo Sender, PlayerReplicationInfo Recipient, name messagetype, byte messageID, name broadcasttype, optional Pawn soundSender, optional vector senderLocation)
{
	local Controller P;
	local ROPlayer ROP;

	if ( (Recipient == None) && !AllowVoiceMessage(MessageType) )
		return;

	for ( P=Level.ControllerList; P!=None; P=P.NextController )
	{
	    ROP = ROPlayer(P);
		if ( ROP != None )
		{
			if ((ROP.PlayerReplicationInfo == Sender) ||
				(ROP.PlayerReplicationInfo == Recipient &&
				 (Level.Game.BroadcastHandler == None ||
				  Level.Game.BroadcastHandler.AcceptBroadcastSpeech(ROP, Sender)))
				)
				ROP.ClientLocationalVoiceMessage(Sender, Recipient, messagetype, messageID, soundSender, senderLocation);
			else if ( (Recipient == None) || (Level.NetMode == NM_Standalone) )
			{
				//if ( (broadcasttype == 'GLOBAL') || !Level.Game.bTeamGame || (Sender.Team == P.PlayerReplicationInfo.Team) )
					if ( Level.Game.BroadcastHandler == None || Level.Game.BroadcastHandler.AcceptBroadcastSpeech(ROP, Sender) )
						ROP.ClientLocationalVoiceMessage(Sender, Recipient, messagetype, messageID, soundSender, senderLocation);
			}
		}
		else if ( (messagetype == 'ORDER') && ((Recipient == None) || (Recipient == P.PlayerReplicationInfo)) )
			P.BotVoiceMessage(messagetype, messageID, self);
	}
}

function AvoidThisVehicle(ROVehicle Feared)       
{
	if ( Vehicle(Pawn) != None )
		return;
	GoalString = "VEHICLE AVOID!";
	AvoidVehicle = Feared;
	GotoState('VehicleAvoid');
}

// State for being startled by something, the bot attempts to move away from it
state VehicleAvoid     //Dynamit: avoid only friendly vehicles!
{
	ignores EnemyNotVisible,SeePlayer,HearNoise;

	function AvoidThisVehicle(ROVehicle Feared)
	{
		GoalString = "AVOID VEHICLE!";
		// Switch to the new guy if he is closer
		if (VSizeSquared(Pawn.Location - Feared.Location) < VSizeSquared(Pawn.Location - AvoidVehicle.Location))
		{
			AvoidVehicle = Feared;
			BeginState();
		}
	}

	function BeginState()
	{
		SetTimer(0.4,true);
	}

	event Timer()
	{
		local vector dir, side;
		local float dist;

		if (Vehicle(Pawn) != None || AvoidVehicle == None || AvoidVehicle.Velocity dot (Pawn.Location - AvoidVehicle.Location) < 0)
		{
			WhatToDoNext(11);
			return;
		}
		Pawn.bIsWalking = false;
		Pawn.bWantsToCrouch = False;
		dir = Pawn.Location - AvoidVehicle.Location;
		dist = VSize(dir);
		if (dist <= AvoidVehicle.CollisionRadius*NearMult)
			HitTheDirt();
		else if (dist < AvoidVehicle.CollisionRadius*FarMult)
		{
			side = dir cross vect(0,0,1);
			// pick the shortest direction to move to
			if (side dot AvoidVehicle.Velocity > 0)
				Destination = Pawn.Location + (-Normal(side) * (AvoidVehicle.CollisionRadius*FarMult));
			else
				Destination = Pawn.Location + (Normal(side) * AvoidVehicle.CollisionRadius*FarMult);

			GoalString = "AVOID VEHICLE!   Moving my arse..";
		}
	}

	function HitTheDirt()
	{
		local vector dir, side;

		GoalString = "AVOID VEHICLE!   Jumping!!!";
		dir = Pawn.Location - AvoidVehicle.Location;
		side = dir cross vect(0,0,1);
		Pawn.Velocity = Pawn.AccelRate * Normal(side);
		// jump the other way if its shorter
		if (side dot AvoidVehicle.Velocity > 0)
			Pawn.Velocity = -Pawn.Velocity;
		Pawn.Velocity.Z = Pawn.JumpZ;
		bPlannedJump=True;
		Pawn.SetPhysics(PHYS_Falling);
		// yell at the jerk if he's "friendly"
		if (Level.TimeSeconds > LastFriendlyFireYellTime+2 && AvoidVehicle != None && GetTeamNum() == AvoidVehicle.GetTeamNum())
		{
			LastFriendlyFireYellTime = Level.TimeSeconds;
			YellAt(AvoidVehicle);
		}
	}

	function EndState()
	{
		bTimerLoop = False;
		AvoidVehicle=None;
		Focus=None;
	}

Begin:
	WaitForLanding();
	MoveTo(Destination,AvoidVehicle,False);
	if (AvoidVehicle == None || VSize(Pawn.Location - AvoidVehicle.Location) > AvoidVehicle.CollisionRadius*FarMult || AvoidVehicle.Velocity dot (Pawn.Location - AvoidVehicle.Location) < 0)
	{
		WhatToDoNext(11);
		warn("!! " @ Pawn.GetHumanReadableName() @ " STUCK IN AVOID VEHICLE !!");
		GoalString = "!! STUCK IN AVOID VEHICLE !!";
	}
	Sleep(0.2);
	GoTo('Begin');

}

function CheckVehicleRoute();

// State for bot vehicle drivers to avoid other pawns
//state VehicleReroute{return;}     //dont call these states at all

//state WaitForCrew{return;}

function VehicleFightEnemy(bool bCanCharge, float EnemyStrength);

function SetAttractionState()
{
   local int i;

	if ( Enemy != None )
	{
	   if(ROVehicle(Pawn) != none)
	   {
		   for(i=0; i < ROVehicle(Pawn).WeaponPawns.Length; i++)
		   {
		      if(ROVehicle(Pawn).WeaponPawns[i] == none)
		          break;
		      if(ROVehicleWeaponPawn(ROVehicle(Pawn).WeaponPawns[i]).Driver == none)
		      {
			   if(ROVehicle(Pawn).WeaponPawns[i].isA('ROTankCannonPawn'))
			   {
				  ChooseAttackMode();
				  return;
			   }
			}
		 }
	   }
		GotoState('FallBack');
	}
	else
		GotoState('Roaming');
}


//BELLOW PARENT CLASS RELATED STUFF

function SetPawnClass(string inClass, string inCharacter)
{
    local class<Pawn> pClass;

    if ( inClass == "" )
		return;
    pClass = class<Pawn>(DynamicLoadObject(inClass, class'Class'));
    if ( pClass != None )
        PawnClass = pClass;
}

state Hunting // extends Hunting //MoveToGoalWithEnemy
{
ignores EnemyNotVisible;

	/* MayFall() called by] engine physics if walking and bCanJump, and
		is about to go off a ledge.  Pawn has opportunity (by setting
		bCanJump to false) to avoid fall
	*/
	function bool IsHunting()
	{
		return true;
	}

	function MayFall()
	{
		Pawn.bCanJump = ( (MoveTarget == None) || (MoveTarget.Physics != PHYS_Falling) || !MoveTarget.IsA('Pickup') );
	}

	function NotifyTakeHit(pawn InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
	{
		LastUnderFire = Level.TimeSeconds;
		Super.NotifyTakeHit(InstigatedBy,HitLocation, Damage,DamageType,Momentum);
		if ( (Pawn.Health > 0) && (Damage > 0) )
			bFrustrated = true;
	}

	function SeePlayer(Pawn SeenPlayer)
	{
		if ( SeenPlayer == Enemy )
		{
			VisibleEnemy = Enemy;
			EnemyVisibilityTime = Level.TimeSeconds;
			bEnemyIsVisible = true;
			BlockedPath = None;
			Focus = Enemy;
			WhatToDoNext(22);
		}
		else
			Global.SeePlayer(SeenPlayer);
	}

	function Timer()
	{
		SetCombatTimer();
		StopFiring();
	}

	function PickDestination()
	{
		local vector nextSpot, ViewSpot,Dir;
		local float posZ;
		local bool bCanSeeLastSeen;
		local int i;

		// If no enemy, or I should see him but don't, then give up ?????????????? WTF
		if ( (Enemy == None) || (Enemy.Health <= 0) )
		{
			LoseEnemy();
			WhatToDoNext(23);
			return;
		}

		if ( Pawn.JumpZ > 0 )
			Pawn.bCanJump = true;

		if ( ActorReachable(Enemy) )
		{
			BlockedPath = None;
			if ( (LostContact(5) && (((Enemy.Location - Pawn.Location) Dot vector(Pawn.Rotation)) < 0))
				&& LoseEnemy() )
			{
				WhatToDoNext(24);
				return;
			}
			Destination = Enemy.Location;
			MoveTarget = None;
			return;
		}

		ViewSpot = Pawn.Location + Pawn.BaseEyeHeight * vect(0,0,1);
		bCanSeeLastSeen = bEnemyInfoValid && FastTrace(LastSeenPos, ViewSpot);

		if ( Squad.BeDevious() )
		{
			if ( BlockedPath == None )
			{
				// block the first path visible to the enemy
				if ( FindPathToward(Enemy,false) != None )
				{
					for ( i=0; i<16; i++ )
					{
						if ( NavigationPoint(RouteCache[i]) == None )
							break;
						else if ( Enemy.Controller.LineOfSightTo(RouteCache[i]) )
						{
							BlockedPath = NavigationPoint(RouteCache[i]);
							break;
						}
					}
				}
				else if ( CanStakeOut() )
				{
					GoalString = "Stakeout from hunt";
					GotoState('StakeOut');
					return;
				}
				else if ( LoseEnemy() )
				{
					WhatToDoNext(25);
					return;
				}
				else
				{
					GoalString = "Retreat from hunt";
					DoRetreat();
					return;
				}
			}
			// control path weights
			if ( BlockedPath != None )
				BlockedPath.TransientCost = 1500;
		}
		if ( FindBestPathToward(Enemy, true,true) )
			return;

		if ( bSoaking && (Physics != PHYS_Falling) )
			SoakStop("COULDN'T FIND PATH TO ENEMY "$Enemy);

		MoveTarget = None;
		if ( !bEnemyInfoValid && LoseEnemy() )
		{
			WhatToDoNext(26);
			return;
		}

		Destination = LastSeeingPos;
		bEnemyInfoValid = false;
		if ( FastTrace(Enemy.Location, ViewSpot)
			&& VSize(Pawn.Location - Destination) > Pawn.CollisionRadius )
			{
				SeePlayer(Enemy);
				return;
			}

		posZ = LastSeenPos.Z + Pawn.CollisionHeight - Enemy.CollisionHeight;
		nextSpot = LastSeenPos - Normal(Enemy.Velocity) * Pawn.CollisionRadius;
		nextSpot.Z = posZ;
		if ( FastTrace(nextSpot, ViewSpot) )
			Destination = nextSpot;
		else if ( bCanSeeLastSeen )
		{
			Dir = Pawn.Location - LastSeenPos;
			Dir.Z = 0;
			if ( VSize(Dir) < Pawn.CollisionRadius )
			{
				GoalString = "Stakeout 3 from hunt";
				GotoState('StakeOut');
				return;
			}
			Destination = LastSeenPos;
		}
		else
		{
			Destination = LastSeenPos;
			if ( !FastTrace(LastSeenPos, ViewSpot) )
			{
				// check if could adjust and see it
				if ( PickWallAdjust(Normal(LastSeenPos - ViewSpot)) || FindViewSpot() )
				{
					if ( Pawn.Physics == PHYS_Falling )
						SetFall();
					else
						GotoState('Hunting', 'AdjustFromWall');
				}
				else if ( (Pawn.Physics == PHYS_Flying) && LoseEnemy() )
				{
					WhatToDoNext(411);
					return;
				}
				else
				{
					GoalString = "Stakeout 2 from hunt";
					GotoState('StakeOut');
					return;
				}
			}
		}
	}

	function bool FindViewSpot()
	{
		local vector X,Y,Z;
		local bool bAlwaysTry;

		if ( Enemy == None )
			return false;

		GetAxes(Rotation,X,Y,Z);

		// try left and right
		// if frustrated, always move if possible
		bAlwaysTry = bFrustrated;
		bFrustrated = false;

		if ( FastTrace(Enemy.Location, Pawn.Location + 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location + 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}

		if ( FastTrace(Enemy.Location, Pawn.Location - 2 * Y * Pawn.CollisionRadius) )
		{
			Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}
		if ( bAlwaysTry )
		{
			if ( FRand() < 0.5 )
				Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			else
				Destination = Pawn.Location - 2.5 * Y * Pawn.CollisionRadius;
			return true;
		}

		return false;
	}

	function BeginState()
	{
		Pawn.bWantsToCrouch = Squad.CautiousAdvance(self);
		//SetAlertness(0.5);
	}

	function EndState()
	{
		if ( (Pawn != None) && (Pawn.JumpZ > 0) )
			Pawn.bCanJump = true;
	}

AdjustFromWall:
	MoveTo(Destination, MoveTarget);

Begin:
	WaitForLanding();
	if ( CanSee(Enemy) )
		SeePlayer(Enemy);
	PickDestination();
SpecialNavig:
	if (MoveTarget == None)
		MoveTo(Destination);
	else                                                         //no strafing
		MoveToward(MoveTarget,FaceActor(10),,(FRand() < 0.75)); // && ShouldStrafeTo(MoveTarget));

	WhatToDoNext(27);
	if ( bSoaking )
		SoakStop("STUCK IN HUNTING!");
}


event bool NotifyBump(Actor Other);


function Restart()
{
	Enemy = None;
	Sentry = Shepard(Pawn);
	GoToState('WakeUp');
}

//function SeeMonster( Pawn Seen )
//{
//	ChangeEnemy(Seen);
//}



//function HearNoise( float Loudness, Actor NoiseMaker)
//{
//	if( NoiseMaker!=None && NoiseMaker.Instigator!=None && FastTrace(NoiseMaker.Location,Pawn.Location) )
//		ChangeEnemy(NoiseMaker.Instigator);
//}

function SeePlayer( Pawn Seen )
{
	if(Seen.Controller.GetTeamNum() !=0) //Dynamit: if seen is Allies then attack!
    ChangeEnemy(Seen);
}

function damageAttitudeTo(pawn Other, float Damage)       //
{
	ChangeEnemy(Other);
}

function ChangeEnemy( Pawn Other )
{
	if( Other==None || Other.Health<=0 || Other.Controller==None || Other==Enemy )
		return;
	if( Sentry.OwnerPawn==None && ROPawn(Other)!=None )
	{
		Sentry.SetOwningPlayer(Other,None);
		return;
	}
	if( RoPawn(Other)==None) // && Pawn(other).Controller.GetTeamNum !=0 ) //we dont use monsters in RO do we?
		return;

	if( Enemy!=None && Enemy.Health<=0 )
		Enemy = None;

	// Current enemy is visible,
	if( Enemy!=None && ((LineOfSightTo(Enemy) && !LineOfSightTo(Other)) || VSizeSquared(Other.Location-Pawn.Location)>VSizeSquared(Enemy.Location-Pawn.Location)) )
		return;

	Enemy = Other;
	EnemyChangedDog();                  //DYNAMIT: THIS IS NOT USED
}

function EnemyChangedDog(); //AS SEEN BELLOW (HERE)

final function GoNextOrders()
{
//	bIsPlayer = true; // Make sure it is set so zeds fight me.      //disable this for now!

	if( Sentry.OwnerPawn==None || Sentry.OwnerPawn.Health<=0 )
	{
		Sentry.OwnerPawn = None;
		Sentry.PlayerReplicationInfo = None;
	}
	if( Enemy!=None && Enemy.Health>=0 && VSize(Sentry.Location-Enemy.Location)<1000 && (Sentry.OwnerPawn==None || LineOfSightTo(Sentry.OwnerPawn)) )
	{
		if(VSize(Sentry.Location-Enemy.Location)>=150.f)
			GoToState('FollowEnemy','Begin');
		else
		log("GOING TO STATE FIGHT ENEMY DOG LINE 1326");
        	GoToState('FightEnemyDog','Begin');     //is not fight enemy dog
		return;
	}
	else Enemy = None;
	GoToState('FollowOwner','Begin');
}

function PawnDied(Pawn P)
{
	if ( Pawn==P )
		Destroy();
}

State WakeUp
{
Ignores SeePlayer,HearNoise,SeeMonster;

Begin:
	Sentry.SetAnimationNum(1);
	WaitForLanding();
	Sentry.SetAnimationNum(0);
	Sleep(1.f);
	GoNextOrders();
}

State FightEnemyDog //error expected state got function   fight enemy is function....
{
//dynamit adds	 ignores SeePlayer, HearNoise;

    function EnemyChangedDog()     //Just use other function
	{
		Sentry.Speech(2);
		if( Sentry.RepAnimationAction!=0 )
			Sentry.SetAnimationNum(0);
		GoToState(,'Begin');
	}
	function BeginState()
	{
		Sentry.Speech(2);
	}
	function EndState()
	{
		if( Sentry.RepAnimationAction!=0 )
			Sentry.SetAnimationNum(0);
		Sentry.Speech(3);
	}
Begin:
	log("STATE FIGHTENEMYDOG:BEGIN!");
    SetTimer(0.1,false);
	if( Enemy==None || Enemy.Health<=0 )
	{
BadEnemy:
		log("STATE FIGHTENEMYDOG:BAD ENEMY!");
        Enemy = None;
		GoNextOrders();
	}
	if( VSize(Enemy.Location-Sentry.Location)<150 )
		GoTo 'ShootEnemy';
	MoveTarget = FindPathToward(Enemy);
	if( MoveTarget==None || (Sentry.OwnerPawn!=None && !LineOfSightTo(Sentry.OwnerPawn)) )
		GoTo'BadEnemy';
	MoveToward(MoveTarget);
	GoTo'Begin';
ShootEnemy:
	log("STATE FIGHTENEMYDOG:SHOOT ENEMY!");
    if( Sentry.OwnerPawn!=None && !LineOfSightTo(Sentry.OwnerPawn) )
	{
		MoveTarget = FindPathToward(Sentry.OwnerPawn);
		if( MoveTarget==None )
			GoTo'BadEnemy';
		MoveToward(MoveTarget);
		GoTo'Begin';
	}
	Focus = Enemy;
	Pawn.Acceleration = vect(0,0,0);
	FinishRotation();
	Sentry.SetAnimationNum(2);
	while( Enemy!=None && Enemy.Health>0 && VSize(Enemy.Location-Sentry.Location)<50 && LineOfSightTo(Enemy) && (Sentry.OwnerPawn==None || LineOfSightTo(Sentry.OwnerPawn)) )
	{
		Pawn.Acceleration = vect(0,0,0);
		if( Enemy.Controller!=None )
			Enemy.Controller.damageAttitudeTo(Pawn,5);
		Sleep(0.35f);
	}
	//Sentry.SetAnimationNum(3);
	Sleep(0.45f);
	GoTo'Begin';
}

State FollowOwner
{
	//Ignores HearNoise,SeeMonster;

	function bool NotifyBump(Actor Other)     //kf monster is now ROPawn
	{
		if( ROPawn(Other)!=None && ROPawn(Other).Health>0 && ROPawn(Other).Controller.GetTeamNum() != Sentry.OwnerPawn.Controller.GetTeamNum() ) // Step aside from a player.
		{ //Dynamit: if Dog bumps at enemy during following dog will attack the enemy?
            log("STATE FOLLOWING OWNER:ABOUT TO CHANGE AND FIGHT ENEMY");
            ChangeEnemy( ROPawn(Other) );
			//GoToState('FightEnemyDog','Begin');   //fightenemydog
		    log("GOING TO STATE FIGHT ENEMY DOG LINE 1424");
            GoToState('FightEnemyDog','Begin');
        }     //kfpawn other
		else if( ROPawn(Other)!=None ) // Step aside from a player.
		{      //we step asside when we bump into friendly. BUT if we bump at enemy dog tries to get as far as possible.
			log("STATE FOLLOWING OWNER:ABOUT TO STEP ASIDE");
            Destination = (Normal(Pawn.Location-Other.Location)+VRand()*0.35)*(Other.CollisionRadius+30.f+FRand()*50.f)+Pawn.Location;
			GoToState(,'StepAside');

        }
		return false;
	}
//	final function CheckShopTeleport()
//	{
//		local ShopVolume S;
       // local Spawnvolume;

//        foreach Pawn.TouchingActors(Class'ShopVolume',S)
//		{
//			if( !S.bCurrentlyOpen && S.TelList.Length>0 )
//				S.TelList[Rand(S.TelList.Length)].Accept( Pawn, S );
//			return;
//		}
//	}
Begin:
	SetTimer(0.1,false);
//	CheckShopTeleport(); // Make sure not stuck inside trader.
//	Disable('NotifyBump');
	if( Sentry.OwnerPawn==None || (VSizeSquared(Sentry.OwnerPawn.Location-Pawn.Location)<160000.f && LineOfSightTo(Sentry.OwnerPawn)) )
	{
		if( bLostContactToPL )
		{
			Sentry.Speech(6);
			bLostContactToPL = false;
		}
Idle:
		Enable('NotifyBump');
		Focus = None;
		FocalPoint = VRand()*20000.f+Pawn.Location;
		FocalPoint.Z = Pawn.Location.Z;
		Pawn.Acceleration = vect(0,0,0);
		Sleep(0.4f+FRand());
	}
	else if( ActorReachable(Sentry.OwnerPawn) )
	{
		Enable('NotifyBump');
		MoveTo(Sentry.OwnerPawn.Location+VRand()*(Sentry.OwnerPawn.CollisionRadius+80.f));
	}
	else
	{
		if( !bLostContactToPL )
		{
			Sentry.Speech(7);
			bLostContactToPL = true;
		}
		MoveTarget = FindPathToward(Sentry.OwnerPawn);
		if( MoveTarget!=None )
			MoveToward(MoveTarget);
		else
		{
			Sentry.Speech(1);
			GoTo'Idle';
		}
	}
	GoNextOrders();
StepAside:
	MoveTo(Destination);
	GoNextOrders();
}

State FollowEnemy   //ok this seems good!                                                              //check sentry team!!!
{
	function bool NotifyBump(Actor Other)
	{
		if( ROPawn(Other)!= None && ROPawn(Other).Health>0 && ROPawn(Other).Controller.GetTeamNum() != Pawn.Controller.GetTeamNum()  ) // Step aside from a player.
		{
		log("STATE FOLLOW ENEMY:ABOUT TO CHANGE ENEMY");
        	ChangeEnemy( ROPawn(Other) );
			GoToState('FightEnemyDog','Begin');  //DOG
		}
		return false;
	}
Begin:
	Enable('NotifyBump');
	if( Enemy==None/* || (VSize(Enemy.Location-Pawn.Location)>=50.f)*/ )
	{
		if( bLostContactToPL )
		{
			Sentry.Speech(6);
			bLostContactToPL = false;
		}
Idle:
		log("STATE FOLLOW ENEMY:ABOUT TO GO IDLE");
        Focus = None;
		FocalPoint = VRand()*20000.f+Pawn.Location;
		FocalPoint.Z = Pawn.Location.Z;
		Pawn.Acceleration = vect(0,0,0);
		Sleep(0.4f+FRand());
Follow:
	}
	else if( ActorReachable(Enemy) )
	{
		Enable('NotifyBump');
		//MoveTo(Enemy.Location/*+VRand()*(Enemy.CollisionRadius)*/);
		MoveTarget = FindPathToward(Enemy);
		if( MoveTarget!=None )
		{
			MoveToward(Enemy);
			if(VSize(Enemy.Location-Pawn.Location)<150.f)
				GoToState('FightEnemyDog','Begin');
			else
				GoTo('Follow');
		}
	}
	else
	{
		if( !bLostContactToPL )
		{
			Sentry.Speech(7);
			bLostContactToPL = true;
		}
		MoveTarget = FindPathToward(Enemy);
		if( MoveTarget!=None )
			MoveToward(MoveTarget);
		else
		{
			Sentry.Speech(1);
			GoTo('Idle');
		}
	}
	GoNextOrders();
StepAside:
	MoveTo(Destination);
	GoNextOrders();
}

defaultproperties
{
    bHunting=True
    // DesiredRole=-1
    // CurrentRole=-1
    // PrimaryWeapon=-1
    // SecondaryWeapon=-1
    // GrenadeWeapon=-1
    // NearMult=1.500000
     //FarMult=3.000000
     //RepeatDodgeFrequency=3.000000
     OrderNames(0)="Attack"
     OrderNames(1)="Defend"
     OrderNames(2)="HOLD"
     OrderNames(5)="Defend"
     OrderNames(6)="Attack"
     OrderNames(7)="HOLD"
     //PlayerReplicationInfoClass=Class'ROEngine.ROPlayerReplicationInfo'
     PawnClass=Class'ROEngine.ROPawn'
}
