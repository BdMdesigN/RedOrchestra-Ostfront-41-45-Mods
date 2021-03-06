//=============================================================================
// ROPawn
//=============================================================================
class RMFPawn extends ROEngine.ROPawn;

#exec OBJ LOAD FILE=..\Sounds\RMFSounds.uax
//#exec OBJ LOAD FILE=..\Sounds\RMFCharge.uax
#exec OBJ LOAD FILE=..\Textures\RMFSkins_Heads.utx
#exec OBJ LOAD FILE=..\Textures\RMFTextures.utx


////////////////////////////////////////////////////////////////////////
// •Пђ”
////////////////////////////////////////////////////////////////////////
var int ChargeStaminaLimit;		// ‹©‚Сђє‚МѓXѓ^ѓ~ѓiђ§ЊА
var int WhisleStaminaLimit;		// “J‚МѓXѓ^ѓ~ѓiђ§ЊА

var	Material SleeveTexture;		// ‘іѓeѓNѓXѓ`ѓѓ
var array<string> GerFaceName;	// ѓhѓCѓcЉз
var array<string> RusFaceName;	// ѓ\ѓrѓGѓgЉз
	
//var FireEffect BodyFire[16];	// ‰Љ‚МѓGѓtѓFѓNѓg
//var BodyDamageFire DamageFire;	// ѓ_ѓЃЃ[ѓW‰Љ
//var bool bBurn;					// ”R‚¦‚Д‚ў‚й‚©
//var int SkinDamage;				// ”з•†
//var int BurnCount;				// ”з•†

//var	Material BurnOverlay[4];	// ”з•†‚М”R‚¦ѓ}ѓeѓЉѓAѓ‹

//var sound  ScreamSound;			// ”R‚¦‚Д‚йЋћ‚М”Я–В
//var sound  FireSound;			// ‰Љ‚М‰№
//var sound  EndSound;			// ’Б‰ОѓTѓEѓ“ѓh


//var BodyFireEffect BFE;			// ‰ЉѓGѓtѓFѓNѓg

// Collision
//var		ROBulletWhipAttachment  AuxCollisionCylinderRMF[10];   	// “–‚Ѕ‚и”»’и—pѓRѓЉѓWѓ‡ѓ“

var bool bCloseWall;

var RODummyAttachment Accessory;

var float BlindAmountV;
var float BlindAmountH;
var vector MaxBlindPositionU;
var vector MaxBlindPositionL;
var vector MaxBlindPositionR;
var bool bBlindPosition;

// ѓЉѓAѓ‹ѓ^ѓCѓЂѓVѓѓѓhѓE
var Effect_ShadowController RealtimeShadow;
var bool bRealtimeShadows;

////////////////////////////////////////////////////////////////////////
// replication
////////////////////////////////////////////////////////////////////////
replication
{
	//ѓTЃ[ѓo‚©‚зѓNѓ‰ѓCѓAѓ“ѓg‚Ц•Ўђ»‚·‚й•Пђ”
//	reliable if( Role==ROLE_Authority )
//		bBurn, BFE;
	
	reliable if (bNetDirty && Role == ROLE_Authority)
		bBlindPosition;//;

	//ѓNѓ‰ѓCѓAѓ“ѓg‚©‚з ѓTЃ[ѓoЉЦђ”‚МЊД‚СЏo‚µ
	reliable if( Role<ROLE_Authority )
        Syouhei, CalcWeight;//, BurningPawn;, Whistle, Charge;

	//ѓTЃ[ѓo‚©‚з ѓNѓ‰ѓCѓAѓ“ѓgЉЦђ”‚МЊД‚СЏo‚µ
	reliable if( Role==ROLE_Authority )
       ChargeVoice, Whistle;
}

simulated function UpdateShadow()
{
    if (bActorShadows && bPlayerShadows && (Level.NetMode != NM_DedicatedServer))
    {
        if (PlayerShadow != none)
            PlayerShadow.Destroy();

		// decide which type of shadow to spawn
		if (!bRealtimeShadows)
		{
			PlayerShadow = Spawn(class'ShadowProjector',Self,'',Location);
			PlayerShadow.ShadowActor = self;
			PlayerShadow.bBlobShadow = bBlobShadow;
			PlayerShadow.LightDirection = Normal(vect(1,1,3));
			PlayerShadow.LightDistance = 320;
			PlayerShadow.MaxTraceDistance = 350;
			PlayerShadow.InitShadow();
		}
		else
		{
			//============================
			// ѓЉѓAѓ‹ѓ^ѓCѓЂѓVѓѓѓhѓEђЭ’и
			//============================
			RealtimeShadow = Spawn(class'Effect_ShadowController',self,'',Location);
			RealtimeShadow.Instigator = self;
			RealtimeShadow.Initialize();
			
		}
    }
    else if (PlayerShadow != none && Level.NetMode != NM_DedicatedServer)
    {
        PlayerShadow.Destroy();
        PlayerShadow = none;
    }
}

//=============================================================================
// PostBeginPlay
//=============================================================================
simulated function PostBeginPlay()
{
//	local int i;
	
	Super.PostBeginPlay();

	SleeveTexture = None;

	
	// ‰ЉѓGѓtѓFѓNѓgђЭ’и
//	DamageFire = Spawn(class'BodyDamageFire',self);
//	if( DamageFire != None )
//	{
//		//AttachToBone(DamageFire,'hip');
//		DamageFire.SetOwner(self);
//	}
	
	//============================
	// ‰ЉѓGѓtѓFѓNѓgђЭ’и
	//============================
//	BFE = Spawn(class'BodyFireEffect',self);
//	if( BFE != None )
//	{
//		BFE.SetOwner(self);
//		BFE.SetupFireSeeds();
//	}
	
//	bBurn = false;
//	for(i=0; i<Hitpoints.Length; i++)
//	{
//		BodyFire[i] = Spawn(class'FireEffect',self);
//		if( BodyFire[i] != None )
//		{
//			BodyFire[i].LocBoneName = Hitpoints[i].PointBone;
//			BodyFire[i].SetLocation( GetBoneCoords(Hitpoints[i].PointBone).Origin );
//			BodyFire[i].SetBase(self);
//			BodyFire[i].SetSpawn( bBurn );
//		}
//	}
//	
	//============================
	// ѓ^ѓCѓ}Ѓ[ѓXѓ^Ѓ[ѓg
	//============================
	SetTimer( 1.0, true );
	
	
}

//=============================================================================
// Destroyed
//=============================================================================
simulated function Destroyed()
{
//	local int i;
	
//	if( DamageFire != None )
//	{
//		DamageFire.Destroy();
//	}
	
//	for( i=0; i<Hitpoints.Length; i++)
//	{
//		if( BodyFire[i] != None )
//			BodyFire[i].Destroy();
//	}
	
	//============================
	// ‰ЉѓGѓtѓFѓNѓg”jЉь
	//============================
//	if( BFE != None )
//	{
//		BFE.Destroy();
//	}

	Super.Destroyed();
	
	if( Accessory != none )
	{
		Accessory.Destroy();
	}
}

//-----------------------------------------------------------------------------
// GetDefaultCharacter
//-----------------------------------------------------------------------------
simulated function string GetDefaultCharacter()
{
	local RORoleInfo RI;
	
	RI = ROPlayerReplicationInfo(PlayerReplicationInfo).RoleInfo;
	
	if ( RI.default.Models.Length == 0)
		return "";

	return RI.default.Models[0];
}

//-----------------------------------------------------------------------------
// PossessedBy - Figure out what dummy attachments are needed
//-----------------------------------------------------------------------------

//function PossessedBy(Controller C)
//{
//	Super.PossessedBy(C);
//
//}

//-----------------------------------------------------------------------------
// HelmetShotOff
//-----------------------------------------------------------------------------
simulated function HelmetShotOff(Rotator Rotation)
{
    local DroppedHeadGear Hat;

    if( HeadGear == none )
    {
    	return;
    }

    if( RMFHeadgear( HeadGear ).bIsMetal )
	{
		RMFHeadgear( HeadGear ).PlaySound(sound'RMFSounds.Effects.helmet_hit01', SLOT_None,0.5,,200);
	}
	else
	{
		PlaySound(sound'RMFSounds.Effects.body_hit', SLOT_None, 0.5,,200);
	}
	
	if( FRand() > 0.3 )
	{
		Hat = Spawn( class'DroppedHeadGear',,, HeadGear.Location, HeadGear.Rotation );

	    if( Hat == none )
	        return;

	    Hat.LinkMesh(HeadGear.Mesh);
	    Hat.Skins[0] = HeadGear.Skins[0];
	    

	    HeadGear.Destroy();

	    Hat.Velocity = Velocity + vector(Rotation) * (Hat.MaxSpeed + (Hat.MaxSpeed/2) * FRand());
	    Hat.LifeSpan = Hat.LifeSpan + 2 * FRand() - 1;
	}	
	

	
    
}

//=============================================================================
// Setup
//=============================================================================
simulated function Setup(xUtil.PlayerRecord rec, optional bool bLoadNow)
{
	local Texture Tex;
//	local vector BodyScale;
	
	// ‚Ѕ‚ї‚с‚Ъ‰рЏБ
	rec.Species=Class'RMFEngine.RMFSPECIES_Human';
	Super.Setup(rec, bLoadNow);
	// ѓeѓNѓXѓ`ѓѓѓЌЃ[ѓh
	if( GetTeamNum() == AXIS_TEAM_INDEX )
	{
		Tex = Texture(DynamicLoadObject( GerFaceName[ Rand( default.GerFaceName.Length ) ], class'Material' ) );
	}
	else if( GetTeamNum() == ALLIES_TEAM_INDEX )
	{
		Tex = Texture(DynamicLoadObject( RusFaceName[ Rand( default.RusFaceName.Length ) ], class'Material' ) );
	}
	
	// ѓtѓHЃ[ѓXѓЌЃ[ѓh
	if( Tex != None )
	{
		Level.ForceLoadTexture(Tex);
		Skins[1] = Tex;
	}


/*	// ‘МЊ^
	BodyScale.x = 1 + frand() - frand();
	BodyScale.x = FClamp( BodyScale.x, 0.9, 1.1 );
	BodyScale.y = BodyScale.x;
	BodyScale.z = 1 + frand();
	BodyScale.z = FClamp( BodyScale.z, 1, 1.1 );
	SetDrawScale3D(BodyScale);
	
	if( HeadGear != None )
	{
		HeadGear.SetDrawScale3D(BodyScale);
	}
	*/
	// Handle dummy attachments
//	if (Role == ROLE_Authority)
//	{
	if ( Accessory == None && ROPlayerReplicationInfo(PlayerReplicationInfo) != None)
	{
		if( ROPlayerReplicationInfo(PlayerReplicationInfo).PlayerName == "[RMF]RIKUSYO"  )
		{
			if(FRand() > 0.9)
			{
				Accessory = Spawn( class<RODummyAttachment>(DynamicLoadObject( "RMFGears.RMFGlassesNose", class'Class' )), self );
			}
			else
			{
				if(FRand() > 0.5)
				{
					Accessory = Spawn( class<RODummyAttachment>(DynamicLoadObject( "RMFGears.RMFGlassesOne", class'Class' )), self );
				}
				else
				{
					Accessory = Spawn( class<RODummyAttachment>(DynamicLoadObject( "RMFGears.RMFGlassesTwo", class'Class' )), self );
				}
			}
				
		}
	}	
}
//-----------------------------------------------------------------------------
// PlayTakeHit
//-----------------------------------------------------------------------------
// Process a precision hit
function ProcessLocationalDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, array<int> PointsHit)
{
	local int i;
	
	Super.ProcessLocationalDamage(Damage, instigatedBy, hitlocation, momentum, damageType, PointsHit);
	
	for(i=0; i<PointsHit.Length; i++)
	{
		if (Hitpoints[PointsHit[i]].HitPointType == PHP_Head)
		{
			HelmetShotOff(Rotator(Normal(GetTearOffMomemtum())));
		}
	}

}
//-----------------------------------------------------------------------------
// PlayTakeHit
//-----------------------------------------------------------------------------
function PlayTakeHit(vector HitLocation, int Damage, class<DamageType> DamageType)
{
    local vector direction;
    local rotator InvRotation;
    local float jarscale;
    // This doesn't really fit our system - Ramm
	//PlayDirectionalHit(HitLocation);

	
    if( Level.TimeSeconds - LastPainSound < MinTimeBetweenPainSounds )
        return;

    LastPainSound = Level.TimeSeconds;

    if( HeadVolume.bWaterVolume )
    {
        if( DamageType.IsA('Drowned') )
            PlaySound( GetSound(EST_Drown), SLOT_Pain,1.5*TransientSoundVolume );
        else
            PlaySound( GetSound(EST_HitUnderwater), SLOT_Pain,1.5*TransientSoundVolume );
        return;
    }

    // for standalone and client
    // Cooney
    if ( Level.NetMode != NM_DedicatedServer )
    {
       if ( class<ROWeaponDamageType>(DamageType) != none )
       {
           if (class<ROWeaponDamageType>(DamageType).default.bCauseViewJarring == true
              && ROPlayer(Controller) != none)
           {
               // Get the approximate direction
               // that the hit went into the body
               direction = self.Location - HitLocation;
               // No up-down jarring effects since
               // I dont have the barrel valocity
               direction.Z = 0.0f;
               direction = normal(direction);

               // We need to rotate the jarring direction
               // in screen space so basically the
               // exact opposite of the player's pawn's
               // rotation.
               InvRotation.Yaw = -Rotation.Yaw;
               InvRotation.Roll = -Rotation.Roll;
               InvRotation.Pitch = -Rotation.Pitch;
               direction = direction >> InvRotation;

               jarscale = 0.1f + (Damage/50.0f);
               if ( jarscale > 1.0f ) jarscale = 1.0f;

               ROPlayer(Controller).PlayerJarred(direction,jarscale);
           }
       }
    }

	// ѓqѓbѓgѓTѓEѓ“ѓh
	PlaySound(sound'RMFSounds.Effects.body_hit', SLOT_None, 0.5,,200);
//	PlayOwnedSound(SoundGroupClass.static.GetHitSound(DamageType), SLOT_Pain,3*TransientSoundVolume,,200);
}

//-----------------------------------------------------------------------------
// Died
//-----------------------------------------------------------------------------
//function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
//{
//	super.Died(Killer, damageType, HitLocation);
//	
//    if(bBurn)
//    {
//		if( DamageFire != None )
//		{
//			DamageFire.SetScreamSound( false );
//		}    	
//    }
//}


//-----------------------------------------------------------------------------
// AddDefaultInventory - Add inventory based on role and weapons choices
//-----------------------------------------------------------------------------
// MergeTODO: This doesn't seem too bad, except we need to turn nades back on for bots at some point
function AddDefaultInventory()
{
	local int i;
	local string S;
	local ROPlayer P;
	local ROBot B;
	local RORoleInfo RI;

//	ClientMessage("===========AddDefaultInventory============");
	if (Controller == None)
		return;

	P = ROPlayer(Controller);
	B = ROBot(Controller);

	if (IsLocallyControlled())
	{
		if (P != None)
		{
			S = P.GetPrimaryWeapon();

			if (S != "")
			{
				RMFCreateInventory(S, P.GetPrimaryAmmo());
			}

			S = P.GetSecondaryWeapon();

			if (S != "")
			{
				RMFCreateInventory(S, P.GetSecondaryAmmo());
			}

			S = P.GetGrenadeWeapon();

			if (S != "")
			{
				RMFCreateInventory(S, P.GetGrenadeAmmo());
			}

			RI = P.GetRoleInfo();

			if (RI != None)
			{
				for (i = 0; i < RI.GivenItems.Length; i++)
					CreateInventory(RI.GivenItems[i]);
			}
		}
		else if (B != None)
		{
			S = B.GetPrimaryWeapon();

			if (S != "")
			{
				RMFCreateInventory(S, B.GetPrimaryAmmo());
			}

			S = B.GetSecondaryWeapon();

			if (S != "")
			{
				RMFCreateInventory(S, B.GetSecondaryAmmo());
			}

            // Not letting bots have nades till we get code in so bots can use them well - Ramm
/*			S = B.GetGrenadeWeapon();

			if (S != "")
				CreateInventory(S); 

			RI = B.GetRoleInfo();

			if (RI != None)
			{
				for (i = 0; i < RI.GivenItems.Length; i++)
					CreateInventory(RI.GivenItems[i]);
			}*/
		}

		Level.Game.AddGameSpecificInventory(self);
	}
	else
	{
		Level.Game.AddGameSpecificInventory(self);

		if (P != None)
		{
			RI = P.GetRoleInfo();

			if (RI != None)
			{
				for (i = RI.GivenItems.Length - 1; i >= 0; i--)
					CreateInventory(RI.GivenItems[i]);
			}

			S = P.GetGrenadeWeapon();

			if (S != "")
			{
				RMFCreateInventory(S, P.GetGrenadeAmmo());
			}

			S = P.GetSecondaryWeapon();

			if (S != "")
			{
				RMFCreateInventory(S, P.GetSecondaryAmmo());
			}

			S = P.GetPrimaryWeapon();
			if (S != "")
			{
				RMFCreateInventory(S, P.GetPrimaryAmmo());
			}

		}
	}

    NetUpdateTime = Level.TimeSeconds - 1;

	// HACK FIXME
	if (Inventory != None)
		Inventory.OwnerEvent('LoadOut');

	if( Level.Netmode == NM_Standalone || Level.Netmode == NM_ListenServer && IsLocallyControlled())
	{
		bRecievedInitialLoadout = true;
		Controller.ClientSwitchToBestWeapon();
		//ClientMessage("SPICES=:"$self.Species);
	}
	
}

//-----------------------------------------------------------------------------
// PossessedBy - Figure out what dummy attachments are needed
//-----------------------------------------------------------------------------

//function PossessedBy(Controller C)
//{
//	Super.PossessedBy(C);
//
//	//============================
//	// Џd—КЊvЋZ
//	//============================
//	CalcWeight();
//}
/*
//-----------------------------------------------------------------------------
// Tick
//-----------------------------------------------------------------------------
simulated function Tick(float DeltaTime)
{

	local Actor A;
	local Vector HitLoc, HitNormal;
	local Vector Start, End;
	local Vector Tmp;
	local rotator WeaponRotation;
	
	Super.Tick( DeltaTime );

	Start = EyePosition() + Location;
	Tmp = Vector(GetViewRotation()) * 40;
	
	End = EyePosition()+ Location + Tmp;
	
	A = Trace( HitLoc, HitNormal, End, Start, true);
	
//	Spawn(class'DebugSphere',,,Start);
//	Spawn(class'DebugSphere',,,End);
		
//	Level.Game.Broadcast(self, "HitActor="$A);
//	if(A != None)
//	{
//		bCloseWall = true;
//		if (ROWeapon(Weapon) != None)
//		{
//			ROWeapon(Weapon).GotoState('WallWeapon');
//			
//		}
//	}
//	else if( bCloseWall )
//	{
//		bCloseWall = false;
//		if (ROWeapon(Weapon) != None)
//		{
//			ROWeapon(Weapon).GotoState('Idle');
//		}
//	}

}*/
//-----------------------------------------------------------------------------
// RMFCreateInventory - ’e–т’Іђ®‚ ‚и
//-----------------------------------------------------------------------------
function RMFCreateInventory(string InventoryClassName, int DefaultNum )
{
	local Inventory Inv;
	local class<Inventory> InventoryClass;
	
	local int InitialAmount, i;
	local ROProjectileWeapon RPW;
	local ROOneShotWeapon ROW;
	
//	ClientMessage("===========CreateInventory============");

	InventoryClass = Level.Game.BaseMutator.GetInventoryClass(InventoryClassName);
	if( (InventoryClass!=None) && (FindInventoryType(InventoryClass)==None) )
	{
		Inv = Spawn(InventoryClass);
		if( Inv != None )
		{
			Inv.GiveTo(self);
			Inv.PickupFunction(self);
			if ( Inv != None )
			{
				RPW = ROProjectileWeapon(Inv);
				ROW= ROOneShotWeapon(Inv);
				
				if( RPW != None )
				{
					if( DefaultNum == 0 )
					{
					    InitialAmount = RPW.MaxAmmo(0);
						RPW.ConsumeAmmo(0,InitialAmount);
					}

					RPW.PrimaryAmmoArray.Length = DefaultNum;
					
				    InitialAmount = ROWeapon(Inv).MaxAmmo(0);
					
					for( i = 0; i < RPW.PrimaryAmmoArray.Length; i++ )
					{
						RPW.PrimaryAmmoArray[i] = InitialAmount;
					}

					if( RPW.PrimaryAmmoArray.Length == 0 )
					{
						RPW.CurrentMagCount = 0;	
					}
					else
					{
						RPW.CurrentMagCount = RPW.PrimaryAmmoArray.Length - 1;	
					}
				}
				
				if( ROW != None )
				{
					InitialAmount = ROW.AmmoCharge[i] - DefaultNum;
					ROW.ConsumeAmmo(0,InitialAmount);
				}
				
			}
		}
	}
}

/*
//-----------------------------------------------------------------------------
// TossMGAmmo(RO) - toss out MG ammo all players carry
//-----------------------------------------------------------------------------
function TossMGAmmo( Pawn Gunner)
{
	local bool bResupplySuccessful;

	if( bUsedCarriedMGAmmo )
		return;

	if( ROWeapon(Gunner.Weapon) != none && ROWeapon(Gunner.Weapon).Instigator.bBipodDeployed )
	{
		if(ROWeapon(Gunner.Weapon).ResupplyAmmo())
			bResupplySuccessful=true;
	}

	bUsedCarriedMGAmmo = bResupplySuccessful;
	if( bResupplySuccessful )
	{
		if( (ROTeamGame(Level.Game) != none) && (Controller != none)
			&& (Gunner.Controller != none) )
		{
		    // Send notification message to gunner & remove resupply request
		    if (ROPlayer(Gunner.Controller) != none)
		    {
		        ROPlayer(Gunner.Controller).ReceiveLocalizedMessage(
                    class'ROResupplyMessage', 1, Controller.PlayerReplicationInfo);
                if (ROGameReplicationInfo(ROTeamGame(Level.Game).GameReplicationInfo) != none)
                    ROGameReplicationInfo(ROTeamGame(Level.Game).GameReplicationInfo)
                        .RemoveMGResupplyRequestFor(Gunner.Controller.PlayerReplicationInfo);
            }

            // Send notification message to supplier
            if (PlayerController(Controller) != none)
            {
                PlayerController(Controller).ReceiveLocalizedMessage(
                    class'ROResupplyMessage', 0, Gunner.Controller.PlayerReplicationInfo);
		    }

		    // Score point
			ROTeamGame(Level.Game).ScoreMGResupply(Controller, Gunner.Controller);
		}

    	PlayOwnedSound(sound'Inf_Weapons_Foley.ammogive', SLOT_Interact, 1.75,, 10);
	}
}
*/
//-----------------------------------------------------------------------------
// HandlePickup
//-----------------------------------------------------------------------------
//function HandlePickup(Pickup pick)
//{
////	ClientMessage("======HandlePickup======");
//	super.HandlePickup(pick);
//	CalcWeight();
//}
//
////-----------------------------------------------------------------------------
//// TossWeapon
////-----------------------------------------------------------------------------
//function TossWeapon(Vector TossVel)
//{
////	ClientMessage("======TossWeapon======");
//	super.TossWeapon(TossVel);
//	CalcWeight();
//}
/*
//-----------------------------------------------------------------------------
// DeleteInventory
//-----------------------------------------------------------------------------
function DeleteInventory( inventory Item )
{
//	ClientMessage("======DeleteInventory======");
	super.DeleteInventory(Item);
	CalcWeight();
}
*/
//simulated function StartFiring(bool bAltFire, bool bRapid)
//{
//	super.StartFiring( bAltFire, bRapid );
//	
//	if( Weapon != None ) 
//	{
//		if( Weapon.IsA('ROOneShotWeapon') )
//		{
//			//ClientMessage("======StartFiring======");
//			CalcWeight();
//		}
//	}
//}
//-----------------------------------------------------------------------------
// CalcWeight
// ‘•”хЏd—К‚©‚з‘¬“x‚И‚З‚р•ПЌX
//-----------------------------------------------------------------------------
function CalcWeight()
{
	local float Tmp, Tmp2;
	local Inventory Inv;
	local int i;
	
	
	Tmp = 0;

	for( Inv=Inventory; Inv!=None; Inv=Inv.Inventory )
	{
		if( Inv.Mass < 100 )
		{
			if( Inv.IsA('ROOneShotWeapon') )
			{
				for ( i=0; i < ROOneShotWeapon(Inv).AmmoAmount(0); i++ )
				{
					Tmp += Inv.Mass;
				}
			}
			else
			{
				Tmp += Inv.Mass;
			}
		}
	}

	
//	ClientMessage("Weight:"$Tmp$"kg");
	Tmp2 = 1 - Tmp / 75;
	
//	ClientMessage("GearWeight="$GearWeight);
//	ClientMessage("Tmp="$Tmp);
	// €Ъ“®‘¬“x‚И‚З’Іђ®
	AccelRate		= default.AccelRate * Tmp2;
	SprintAccelRate	= default.SprintAccelRate * Tmp2;
	GroundSpeed		= default.GroundSpeed * Tmp2;
	WaterSpeed		= default.WaterSpeed * Tmp2;
	LadderSpeed		= default.LadderSpeed * Tmp2;
	AirSpeed		= default.AirSpeed * Tmp2;
	JumpZ			= default.JumpZ * Tmp2;
}

/*
//-----------------------------------------------------------------------------
// ‹©‚Сђє
//-----------------------------------------------------------------------------
exec function Charge()
{
	local ROPlayerReplicationInfo RPR;

	// ѓXѓ^ѓ~ѓiѓ`ѓFѓbѓN
	if(Stamina > ChargeStaminaLimit)
	{
		// ђ•ЋІ
    	if(GetTeamNum() == AXIS_TEAM_INDEX)
    	{
    		// ROPlayerReplicationInfoЋж“ѕ
    		RPR = ROPlayerReplicationInfo(PlayerReplicationInfo);
    		
    		// •Є‘а’·‚МЋћ‚Мђє
	    	if(RPR.RoleInfo.bIsLeader && !RPR.RoleInfo.bCanBeTankCrew)
	    	{
	    		if( DrivenVehicle == None )
	    		{
					PlaySound(sound'RMFSounds.Charge.german_charge_order', SLOT_None,2.0,,,1.0,false);
				}
				else
				{
					PlaySound(sound'RMFSounds.german_vehicle_charge_order', SLOT_None,1.0,,,1.0,false);
				}
			}
    		// ’КЏн•є‚Мђє
			else
			{
	    		if( DrivenVehicle == None )
	    		{
					PlaySound(sound'RMFSounds.Charge.german_charge', SLOT_None,2.0,,,1.0,false);
				}
				else
				{
					PlaySound(sound'RMFSounds.german_vehicle_charge', SLOT_None,1.0,,,1.0,false);
				}
			}
		}
		else
		{
    		// ROPlayerReplicationInfoЋж“ѕ
    		RPR = ROPlayerReplicationInfo(PlayerReplicationInfo);

    		// •Є‘а’·‚МЋћ‚Мђє
	    	if(RPR.RoleInfo.bIsLeader && !RPR.RoleInfo.bCanBeTankCrew)
	    	{
	    		if( DrivenVehicle == None )
	    		{
					PlaySound(sound'RMFSounds.Charge.russian_charge_order', SLOT_None,2.0,,,1.0,false);
				}
				else
				{
					PlaySound(sound'RMFSounds.russian_vehicle_charge_order', SLOT_None,1.0,,,1.0,false);
				}
			}
    		// ’КЏн•є‚Мђє
			else
			{
	    		if( DrivenVehicle == None )
	    		{
					PlaySound(sound'RMFSounds.Charge.russian_charge', SLOT_None,2.0,,,1.0,false);
				}
				else
				{
					PlaySound(sound'RMFSounds.russian_vehicle_charge', SLOT_None,1.0,,,1.0,false);
				}
			}
		}
		
    	// ѓXѓ^ѓ~ѓiЊёЏ­
	    Stamina = FMax(Stamina - 2.0, 0.0);
	    
	    // ѓNѓ‰ѓCѓAѓ“ѓgѓXѓ^ѓ~ѓiЌXђV
		if (Role == ROLE_Authority)
		{
			ClientForceStaminaUpdate(Stamina);
		}
		
	}
}

//-----------------------------------------------------------------------------
// “J
//-----------------------------------------------------------------------------
exec function Whistle()
{
	local ROPlayerReplicationInfo RPR;

	// ѓXѓ^ѓ~ѓiѓ`ѓFѓbѓN
	if(Stamina > WhisleStaminaLimit)
	{
		// ROPlayerReplicationInfoЋж“ѕ
		RPR = ROPlayerReplicationInfo(PlayerReplicationInfo);

		// •Є‘а’·‚М‚Э
	  	if(RPR.RoleInfo.bIsLeader && !RPR.RoleInfo.bCanBeTankCrew)
	  	{
  		// “J‚М‰№
			PlaySound(sound'RMFSounds.Whistle.ChargeWhistle', SLOT_None,1.0,,,1.0,false);

	    	// ѓXѓ^ѓ~ѓiЊёЏ­
		    Stamina = FMax(Stamina - 2.0, 0.0);
		    // ѓNѓ‰ѓCѓAѓ“ѓgѓXѓ^ѓ~ѓiЌXђV
			if (Role == ROLE_Authority)
			{
				ClientForceStaminaUpdate(Stamina);
			}
	  		
    		// ѓJѓEѓ“ѓ^ђЭ’и
		 	if(WhisleCnt <=  0)
		   		WhisleCnt = 4;
		}
	}

}
*/
////////////////////////////////////////////////////////////////////////
// ѓ^ѓCѓ}Ѓ[
////////////////////////////////////////////////////////////////////////
function Timer()
{
	
	//============================
	// Џd—КЊvЋZ
	//============================
	CalcWeight();


	/*	
	local Material Overlay;
	local int i;
	
	//============================
	// ”R‚¦‚Д‚ў‚йЋћ‚Н”з•†ѓ_ѓЃЃ[ѓW
	//============================
	if( bBurn )
	{
		SkinDamage++;
		BurnCount++;
		
		if( BurnCount == 70 )
		{
			for(i=0; i<Hitpoints.Length; i++)
			{
				if( BodyFire[i] != None )
				{
					BodyFire[i].SetEffectScale(0.5);
				}
			}
		}
		if( BurnCount == 80 )
		{
			for(i=0; i<Hitpoints.Length; i++)
			{
				if( BodyFire[i] != None )
				{
					BodyFire[i].SetEffectScale(0.3);
				}
			}
		}
		if( BurnCount == 90 )
		{
			for(i=0; i<Hitpoints.Length; i++)
			{
				if( BodyFire[i] != None )
				{
					BodyFire[i].SetEffectScale(0.2);
				}
			}
			PlaySound(EndSound, SLOT_None,1.0,,);
		    SoundVolume=0;
		}
		else if( BurnCount == 95 )
		{
			for(i=0; i<Hitpoints.Length; i++)
			{
				if( BodyFire[i] != None )
				{
					BodyFire[i].SetSpawn( false );
				}
			}
			BurnCount = 0;
			bBurn = false;
		}
	}
	
	//============================
	// ѓ_ѓЃЃ[ѓW‚Й‰ћ‚¶‚ДѓXѓLѓ“ѓIЃ[ѓoЃ[ѓЊѓC
	//============================
	if( SkinDamage < 70  )
	{
		if( SkinDamage == 10 )
		{
			Overlay = BurnOverlay[0];
		}
		else if( SkinDamage == 20 )
		{
			Overlay = BurnOverlay[1];
		}
		else if( SkinDamage == 35 )
		{
			Overlay = BurnOverlay[2];
		}
		else if( SkinDamage == 60 )
		{
			Overlay = BurnOverlay[3];
		}
		
		
		//============================
		// ѓIЃ[ѓoЃ[ѓЊѓCђЭ’и
		//============================
		if( Overlay != None )
		{
			SetOverlayMaterial(Overlay, 999, true);
			
			if( HeadGear != None )
			{
				HeadGear.SetOverlayMaterial(Overlay, 999, true);
			}
			
			for (i = 0; i < AmmoPouches.Length; i++)
			{
				if (AmmoPouches[i] != None)
				{
					AmmoPouches[i].SetOverlayMaterial(Overlay, 999, true);
				}
			}			
		}
		
	}
*/
}

//-----------------------------------------------------------------------------
// Ћ©ЋEѓЌѓbѓNѓ}ѓ“
//-----------------------------------------------------------------------------
function Suicide()
{
/*
	if( Role == ROLE_Authority )
	{
	    Level.Game.Broadcast(self, "Role == ROLE_Authority");
	}
	else if( Role < ROLE_Authority )
	{
	    Level.Game.Broadcast(self, "Role < ROLE_Authority");
	}
*/
	PlaySound(sound'RMFSounds.Other.rock_death', SLOT_None,2.0,,,1.0,false);
	super.Suicide();
//	KilledSelf( class'ROSuicided' );
//	TakeDamage(10000, self, Location, Location, class'ROSuicided');
}

//-----------------------------------------------------------------------------
// ѓVѓ‡ѓEѓwѓCѓwЃ[ѓC
//-----------------------------------------------------------------------------
exec function Syouhei()
{

	
//	local float Dist;
//	local ROPawn Victims;

//	foreach VisibleCollidingActors( class 'ROPawn', Victims, 320, Location )
//	{
//		Dist = VSize(Location - Victims.Location);
//		if (Dist < 200 )
//		{
//			if( Victims != None && Victims != self)
//			{
//				//RMFPawn(Victims).bBurn = true;
//				//RMFPawn(Victims).DamageFire.ChangeFireState( true );
//
//				if( RMFPawn(Victims).BFE != None )
//				{
//					if( RMFPawn(Victims).BFE.bBurn )
//					{
//						RMFPawn(Victims).BFE.BurnCount = 11;
//					}
//					else
//					{
//						RMFPawn(Victims).BFE.ChangeState( true );
//					}
//				}					
//				
//			}
//		}
//	}	
	
	
/*
	if( Role == ROLE_Authority )
	{
	    Level.Game.Broadcast(self, "Role == ROLE_Authority");
	}
	else if( Role < ROLE_Authority )
	{
	    Level.Game.Broadcast(self, "Role < ROLE_Authority");
	}
*/
	
//	local RODummyAttachment RDA;
//	
//	RDA = Spawn( class'RMFEngine.RMFGlassesNose', self );
//	
//	if( RDA != None )
//	{
//		AttachToBone( RDA, 'head' );
//	}	

//	BurningPawn();
	
	PlaySound(sound'RMFSounds.Other.SyouheiVoice', SLOT_None,2.0,,,1.0,false);

}

//-----------------------------------------------------------------------------
// ѓfѓtѓHѓ‹ѓg‚ѕ‚Ж‚«‚©‚с‚М‚ЕЃEЃEЃE
//-----------------------------------------------------------------------------
function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
// else UT
// function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType);
{
	local int actualDamage;
	local Controller Killer;
	
	if ( damagetype == None )
	{
		if ( InstigatedBy != None )
			warn("No damagetype for damage by "$instigatedby$" with weapon "$InstigatedBy.Weapon);
		DamageType = class'DamageType';
	}

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	if ( Health <= 0 )
		return;

	if ((instigatedBy == None || instigatedBy.Controller == None) && DamageType.default.bDelayedDamage && DelayedDamageInstigatorController != None)
		instigatedBy = DelayedDamageInstigatorController.Pawn;

	if ( (Physics == PHYS_None) && (DrivenVehicle == None) )
		SetMovementPhysics();
	if (Physics == PHYS_Walking && damageType.default.bExtraMomentumZ)
		momentum.Z = FMax(momentum.Z, 0.4 * VSize(momentum));
	if ( instigatedBy == self )
		momentum *= 0.6;
	momentum = momentum/Mass;

//	Level.Game.Broadcast(self, "Damage1="$Damage);
	
	if (Weapon != None)
		Weapon.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
		
//	Level.Game.Broadcast(self, "Damage2="$Damage);
	
//	if (DrivenVehicle != None)
 //       	DrivenVehicle.AdjustDriverDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
        	
//	Level.Game.Broadcast(self, "Damage3="$Damage);
	
	if ( (InstigatedBy != None) && InstigatedBy.HasUDamage() )
		Damage *= 2;

//	Level.Game.Broadcast(self, "Damage4="$Damage);

	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);
	
//	Level.Game.Broadcast(self, "Damage5="$actualDamage);
	
	if( DamageType.default.bArmorStops && (actualDamage > 0) )
		actualDamage = ShieldAbsorb(actualDamage);
		
//	Level.Game.Broadcast(self, "Damage6="$actualDamage);

	Health -= actualDamage;
	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;


	PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, Momentum);
	if ( Health <= 0 )
	{
		// pawn died
		if ( DamageType.default.bCausedByWorld && (instigatedBy == None || instigatedBy == self) && LastHitBy != None )
			Killer = LastHitBy;
		else if ( instigatedBy != None )
			Killer = instigatedBy.GetKillerController();
		if ( Killer == None && DamageType.Default.bDelayedDamage )
			Killer = DelayedDamageInstigatorController;
		if ( bPhysicsAnimUpdate )
			TearOffMomentum = momentum;
		Died(Killer, damageType, HitLocation);
		
	}
	else
	{
		AddVelocity( momentum );
		if ( Controller != None && DamageType != class'FireDamageType')
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
		if ( instigatedBy != None && instigatedBy != self )
			LastHitBy = instigatedBy.Controller;
	}
	MakeNoise(1.0);
}


//-----------------------------------------------------------------------------
// DoJump - overriden to support a wait time between jumps
//-----------------------------------------------------------------------------
function bool DoJump( bool bUpdating )
{
	local Actor A;
	local Vector HitLoc, HitNormal;
	local Vector Start, End;
	local Vector Tmp;
		
	// No jumping if stamina is too low
	if ((Stamina < JumpStaminaDrain) || (Level.TimeSeconds < NextJumpTime) )
	{
		if(CanJump() && !bUpdating)
		{
			PlayOwnedSound(GetSound(EST_TiredJump), SLOT_Pain, GruntVolume,,80);
		}
		return false;
	}
	

	if ( CanJump() && ((Physics == PHYS_Walking) || (Physics == PHYS_Ladder) || (Physics == PHYS_Spider)))
	{
	
		Start = Location+ Vect(0,0,-10);
		Tmp = Vector(Rotation) * 70;
		
		End = Location + Vect(0,0,-20);
		End.x += Tmp.x; 
		End.y += Tmp.y; 
		
		A = Trace( HitLoc, HitNormal, End, Start, true);
		
//		Spawn(class'DebugSphere',,,Start);
//		Spawn(class'DebugSphere',,,End);
		
//		Level.Game.Broadcast(self, "HitActor="$A);
		if(A != None)
		{
			A = Trace( HitLoc, HitNormal, End+ Vect(0,0,90), Start+ Vect(0,0,90), true);

//			Level.Game.Broadcast(self, "HitActor="$A);
//			Spawn(class'DebugSphere',,,Start+ Vect(0,0,90));
//			Spawn(class'DebugSphere',,,End+ Vect(0,0,90));
			
			if(A == None)
			{
				SetLocation(End+Vect(0,0,90));
				EndProne(End.Z + 90);
				Stamina = FMax(Stamina - JumpStaminaDrain * 1.5, 0.0);
				
				return true;
			}
		}

		// Take stamina away with each jump
		Stamina = FMax(Stamina - JumpStaminaDrain, 0.0);

		if ( Role == ROLE_Authority )
		{
			if ( (Level.Game != None) && (Level.Game.GameDifficulty > 2) )
				MakeNoise(0.1 * Level.Game.GameDifficulty);
			if ( bCountJumps && (Inventory != None) )
				Inventory.OwnerEvent('Jumped');
		}
		
		// For playing jumping anims, etc
		if( Weapon != none )
		{
			Weapon.NotifyOwnerJumped();
		}

		if (!bUpdating)
			PlayOwnedSound(GetSound(EST_Jump), SLOT_Pain, GruntVolume,,80);

		NextJumpTime = Level.TimeSeconds + 2.0;

		if ( Physics == PHYS_Spider )
			Velocity = JumpZ * Floor;
		else if ( Physics == PHYS_Ladder )
			Velocity.Z = 0;
		else if ( bIsWalking )
			Velocity.Z = Default.JumpZ;
		else
			Velocity.Z = JumpZ;
		if ( (Base != None) && !Base.bWorldGeometry )
			Velocity.Z += Base.Velocity.Z;
		SetPhysics(PHYS_Falling);

		return true;
	}

	return false;
}


//=============================================================================
// ЋЂ–S
// ѓIЃ[ѓoЃ[ѓЊѓCђЭ’и
//=============================================================================
/*simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	WeaponState = GS_None;
	if( PlayerController(Controller) != none )
		PlayerController(Controller).bFreeCamera = false;

	AmbientSound = None;
    bCanTeleport = false; // sjs - fix karma going crazy when corpses land on teleporters
    bReplicateMovement = false;
    bTearOff = true;
    bPlayedDeath = true;

	HitDamageType = DamageType; // these are replicated to other clients
    TakeHitLocation = HitLoc;

    if ( DamageType != None )
    {
//		if ( DamageType.Default.DeathOverlayMaterial != None && !class'GameInfo'.static.UseLowGore() )
//    	{
//			SetOverlayMaterial(DamageType.Default.DeathOverlayMaterial, DamageType.default.DeathOverlayTime, true);
//    	}
//		else if ( (DamageType.Default.DamageOverlayMaterial != None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
//    	{
//			SetOverlayMaterial(DamageType.Default.DamageOverlayMaterial, 2*DamageType.default.DamageOverlayTime, true);
//    	}

		if( BFE != None )
		{
	    	if( DamageType.Default.DeathOverlayMaterial == Material'Effects_Tex.PlayerDeathOverlay' )
	    	{
	    		BFE.bDamaged = true;
	    		
				if( BFE.BurnLevel > -1 )
	    		{
	    			SetOverlayMaterial(BFE.BurnOverlay[BFE.BurnLevel].Damaged, 999, true);
	    			Level.Game.Broadcast(self, "A");
	    		}
	    		else
		    	{
	    			SetOverlayMaterial(DamageType.Default.DeathOverlayMaterial, DamageType.default.DeathOverlayTime, false);
	    			Level.Game.Broadcast(self, "B");
		    	}
	   		}
			else
			{
				if( BFE.BurnLevel > -1 )
		    	{
		    		SetOverlayMaterial(BFE.BurnOverlay[BFE.BurnLevel].Normal, 999, true);
	    			Level.Game.Broadcast(self, "C");
		    	}
			}
			
			
		}
//		Level.Game.Broadcast(self, "BFE.bDamaged="$BFE.bDamaged);
//		Level.Game.Broadcast(self, "BFE.BurnLevel="$BFE.BurnLevel);
//		Level.Game.Broadcast(self, "OverlayMaterial="$OverlayMaterial);
	}

    // stop shooting
    AnimBlendParams(1, 0.0);
	LifeSpan = RagdollLifeSpan;

    GotoState('Dying');

	PlayDyingAnimation(DamageType, HitLoc);
}*/

//=============================================================================
// HandleWhizSound ’e‚©‚·‚Я‚ЅѓTѓEѓ“ѓh
//=============================================================================
simulated event HandleWhizSound()
{
 	// Don't play whizz sounds for bots, or from other players
	if ( IsHumanControlled() && IsLocallyControlled() )
	{
		Spawn(class'ROBulletWhiz',,, mWhizSoundLocation);
		RMFPlayer(Controller).PlayerWhizzed(VSizeSquared(Location - mWhizSoundLocation));
	}
}
	
function PlayDyingAnimation(class<DamageType> DamageType, vector HitLoc)
{
	local vector shotDir, hitLocRel, deathAngVel, shotStrength;
	local float maxDim;
	local string RagSkelName;
	local KarmaParamsSkel skelParams;
	local bool PlayersRagdoll;
	local PlayerController pc;

	if ( Level.NetMode != NM_DedicatedServer )
	{
		// Is this the local player's ragdoll?
		if(OldController != None)
			pc = PlayerController(OldController);
		if( pc != None && pc.ViewTarget == self )
			PlayersRagdoll = true;

		if( FRand() < 0.3 )
		{
		//	HelmetShotOff(Rotator(Normal(GetTearOffMomemtum())));
		}

		// In low physics detail, if we were not just controlling this pawn,
		// and it has not been rendered in 3 seconds, just destroy it.
		if( (Level.PhysicsDetailLevel != PDL_High) && !PlayersRagdoll && (Level.TimeSeconds - LastRenderTime > 3) )
		{
			Destroy();
			return;
		}

		// Try and obtain a rag-doll setup. Use optional 'override' one out of player record first, then use the species one.
		if( RagdollOverride != "")
			RagSkelName = RagdollOverride;
		else if(Species != None)
			RagSkelName = Species.static.GetRagSkelName( GetMeshName() );
		else
			Log("xPawn.PlayDying: No Species");

		// If we managed to find a name, try and make a rag-doll slot availbale.
		if( RagSkelName != "" )
		{
			KMakeRagdollAvailable();
		}

		if( KIsRagdollAvailable() && RagSkelName != "" )
		{
			skelParams = KarmaParamsSkel(KParams);
			skelParams.KSkeleton = RagSkelName;

			// Stop animation playing.
			StopAnimating(true);

			if( DamageType != None )
			{
				if ( DamageType.default.bLeaveBodyEffect )
					TearOffMomentum = vect(0,0,0);

				if( DamageType.default.bKUseOwnDeathVel )
				{
					RagDeathVel = DamageType.default.KDeathVel;
					RagDeathUpKick = DamageType.default.KDeathUpKick;
					RagShootStrength = DamageType.default.KDamageImpulse;
				}
			}

			// Set the dude moving in direction he was shot in general
			shotDir = Normal(GetTearOffMomemtum());
			shotStrength = RagDeathVel * shotDir;

			// Calculate angular velocity to impart, based on shot location.
			hitLocRel = TakeHitLocation - Location;



			if( DamageType.default.bLocationalHit )
			{
				hitLocRel.X *= RagSpinScale;
				hitLocRel.Y *= RagSpinScale;

				if( Abs(hitLocRel.X)  > RagMaxSpinAmount )
				{
					if( hitLocRel.X < 0 )
					{
						hitLocRel.X = FMax((hitLocRel.X * RagSpinScale), (RagMaxSpinAmount * -1));
					}
					else
					{
						hitLocRel.X = FMin((hitLocRel.X * RagSpinScale), RagMaxSpinAmount);
					}
				}

				if( Abs(hitLocRel.Y)  > RagMaxSpinAmount )
				{
					if( hitLocRel.Y < 0 )
					{
						hitLocRel.Y = FMax((hitLocRel.Y * RagSpinScale), (RagMaxSpinAmount * -1));
					}
					else
					{
						hitLocRel.Y = FMin((hitLocRel.Y * RagSpinScale), RagMaxSpinAmount);
					}
				}

			}
			else
			{
				// We scale the hit location out sideways a bit, to get more spin around Z.
				hitLocRel.X *= RagSpinScale;
				hitLocRel.Y *= RagSpinScale;
			}

			//log("hitLocRel.X = "$hitLocRel.X$" hitLocRel.Y = "$hitLocRel.Y);
			//log("TearOffMomentum = "$VSize(GetTearOffMomemtum()));

			// If the tear off momentum was very small for some reason, make up some angular velocity for the pawn
			if( VSize(GetTearOffMomemtum()) < 0.01 )
			{
				//Log("TearOffMomentum magnitude of Zero");
				deathAngVel = VRand() * 18000.0;
			}
			else
			{
				deathAngVel = RagInvInertia * (hitLocRel cross shotStrength);
			}

    		// Set initial angular and linear velocity for ragdoll.
			// Scale horizontal velocity for characters - they run really fast!
			if ( DamageType.Default.bRubbery )
				skelParams.KStartLinVel = vect(0,0,0);
			if ( Damagetype.default.bKUseTearOffMomentum )
				skelParams.KStartLinVel = GetTearOffMomemtum() + Velocity;
			else
			{
				skelParams.KStartLinVel.X = 1.0 * Velocity.X;
				skelParams.KStartLinVel.Y = 1.0 * Velocity.Y;
				skelParams.KStartLinVel.Z = 1.0 * Velocity.Z;
    				skelParams.KStartLinVel += shotStrength;
			}
			// if not moving downwards - give extra upward kick
			if( !DamageType.default.bLeaveBodyEffect && !DamageType.Default.bRubbery && (Velocity.Z > -10) )
				skelParams.KStartLinVel.Z += RagDeathUpKick;

			if ( DamageType.Default.bRubbery )
			{
				Velocity = vect(0,0,0);
    			skelParams.KStartAngVel = vect(0,0,0);
    		}
			else
			{
    			skelParams.KStartAngVel = deathAngVel;

    			// Set up deferred shot-bone impulse
				maxDim = Max(CollisionRadius, CollisionHeight);

    			skelParams.KShotStart = TakeHitLocation - (1 * shotDir);
    			skelParams.KShotEnd = TakeHitLocation + (2*maxDim*shotDir);
    			skelParams.KShotStrength = RagShootStrength;
			}

			//log("RagDeathVel = "$RagDeathVel$" KShotStrength = "$skelParams.KShotStrength$" RagDeathUpKick = "$RagDeathUpKick);

    		// If this damage type causes convulsions, turn them on here.
    		if(DamageType != none && DamageType.default.bCauseConvulsions)
    		{
    			RagConvulseMaterial=DamageType.default.DamageOverlayMaterial;
    			skelParams.bKDoConvulsions = true;
		    }

    		// Turn on Karma collision for ragdoll.
			KSetBlockKarma(true);

			// Set physics mode to ragdoll.
			// This doesn't actaully start it straight away, it's deferred to the first tick.
			SetPhysics(PHYS_KarmaRagdoll);

			// If viewing this ragdoll, set the flag to indicate that it is 'important'
			if( PlayersRagdoll )
				skelParams.bKImportantRagdoll = true;

			skelParams.KMass  = 80.0;
//			skelParams.KLinearDamping   = 2.0;
//			skelParams.KAngularDamping    = 2.0;
//			skelParams.KRestitution     = 0.5;
			skelParams.KActorGravScale = RagGravScale;

			return;
		}
		// jag
	}

	// non-ragdoll death fallback
	Velocity += GetTearOffMomemtum();
    BaseEyeHeight = Default.BaseEyeHeight;
    SetTwistLook(0, 0);
    // We don't do this - Ramm
    //PlayDirectionalDeath(HitLoc);
    SetPhysics(PHYS_Falling);
}

//exec function FireSuicide()
//{
////	local float Dist;
////	local ROPawn Victims;
////	
////	foreach VisibleCollidingActors( class 'ROPawn', Victims, 320, Location )
////	{
////		Dist = VSize(Location - Victims.Location);
////		if (Dist < 200 )
////		{
////			if( Victims != None && Victims != self)
////			{
////				//log("Role="$RMFPawn(Victims).Role);
////				RMFPawn(Victims).DamageFire.ChangeFireState( true );
////			}
////		}
////	}	
//}

//exec function FireSuicide2()
//{
//
//	//DamageFire.ChangeFireState( true );
//	//BurningPawn();
//	if( BFE != None )
//	{
//		if( BFE.bBurn )
//		{
//			BFE.BurnCount = 11;
//		}
//		else
//		{
//			BFE.ChangeState( true );
//		}
//	}	
//}

//-----------------------------------------------------------------------------
// BurningPawn
//-----------------------------------------------------------------------------
//function BurningPawn()
//{
////	if( !bBurn )
////	{
////		bBurn = true;
////		
////		if (Role == ROLE_Authority)
////			SetBurningEffect();
////
////		//============================
////		// ђ¶‚«‚Д‚Ѕ‚з”Я–ВЃ@‚»‚¤‚Е‚И‚Ї‚к‚Оѓ^ѓ_‚М”R‚¦‚й‰№
////		//============================
////		if( !bPlayedDeath )
////		{
////			AmbientSound = ScreamSound;
////			
////		}
////		else
////		{
////			AmbientSound = FireSound;
////		}
////		SoundVolume=255;
////	}
//}

////////////////////////////////////////////////////////////////////////
// ѓoѓЊѓ‹ЊрЉ·ѓLЃ[‚Еѓuѓ‰ѓCѓ“ѓhѓtѓ@ѓCѓA
////////////////////////////////////////////////////////////////////////
simulated function ChangeBlindPosition()
{
	if( bBlindPosition )
	{
		bBlindPosition = false;
	}
	else
	{
		bBlindPosition = true;
	}
}	
	
//-----------------------------------------------------------------------------
// Turned this tick back on to do stamina based breathing calculations -Ramm
//-----------------------------------------------------------------------------
simulated function Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);
	
	//=============================================================================
	// ѓuѓ‰ѓCѓ“ѓhѓ|ѓWѓVѓ‡ѓ“
	//=============================================================================
	TickBlindPosition(DeltaTime);
	
	
	if(RMFPlayer(Controller) != None)
	{
//		ClientMessage("RMFPlayer(Controller).SuppressAmount ="$RMFPlayer(Controller).SuppressAmount);

		//=============================================================================
		// ђ§€іѓЃЃ[ѓ^Ѓ[Њё‚з‚·
		//=============================================================================
		if( RMFPlayer(Controller).SuppressAmount > 0)
		{
			RMFPlayer(Controller).SuppressAmount -= 0.02;
		}
	}
}

//=============================================================================
// ѓuѓ‰ѓCѓ“ѓhѓ|ѓWѓVѓ‡ѓ“ђЭ’и
//=============================================================================
simulated function TickBlindPosition(float DeltaTime)
{
	local bool SideBlind;
	SideBlind = true;
	//=============================================================================
	// “Б’иЏрЊЏ‚Е‰рЏњ
	//=============================================================================
    if( Role > ROLE_SimulatedProxy )
    {
		//=============================================================================
		// •ђЉн‚И‚µ‚И‚з‰рЏњ
		//=============================================================================
    	if( Weapon == None )
    	{
			bBlindPosition = false;
    		SideBlind = false;
    	}
    	
		//=============================================================================
		// ‚±‚к‚з‚М•ђЉн‚И‚з‰рЏњ
		//=============================================================================
    	if( ROBipodWeapon(Weapon) != None 
    	||	ROExplosiveWeapon(Weapon) != None
    	||	RORocketWeapon(Weapon) != None 
    	||	BinocularsItem(Weapon) != None )
    	{
			bBlindPosition = false;
    		SideBlind = false;
    	}
    	
    	//=============================================================================
		// •ђЉн‚МЏу‘Ф‚Е‰рЏњ
		//=============================================================================
    	if( WeaponState == GS_PreReload 
    	|| WeaponState == GS_ReloadSingle 
     	|| WeaponState == GS_ReloadLooped 
    	|| WeaponState == GS_ReloadSingle 
   		)
    	{
			bBlindPosition = false;
    		SideBlind = false;
    	}
    	//=============================================================================
		// ‹у’†‚Н‰рЏњ
		//=============================================================================
		if ( (Physics == PHYS_Falling) || (Physics == PHYS_Flying) )
		{
			bBlindPosition = false;
    		SideBlind = false;
		}
    	//=============================================================================
		// €Ъ“®‚Ж‚©Џу‘Ф•П€Щ‚µ‚Ѕ‚з‰рЏњ
		//=============================================================================
		if ( VSize(Velocity) > 60 
		||	IsInState('EndProning') 
		||	IsInState('CrouchingFromProne') 
		||	IsInState('ProningFromCrouch') )
		{
			bBlindPosition = false;
		}
    	//=============================================================================
		// ѓAѓCѓAѓ“ѓTѓCѓg‚Ж‰Ј‚и‚Е‰рЏњ
		//=============================================================================
		if ( bIronSights || bMeleeHolding )
		{
			bBlindPosition = false;
    		SideBlind = false;
		}
    	//=============================================================================
		// ѓ{ѓ‹ѓgѓAѓNѓVѓ‡ѓ“ѓRѓbѓLѓ“ѓO‚Н‰рЏњ
		//=============================================================================
    	if( ROBoltActionWeapon(Weapon) != None )
    	{
    		if( ROBoltActionWeapon(Weapon).IsInState('WorkingBolt') )
    		{
				bBlindPosition = false;
	    		SideBlind = false;
    		}
    	}
    	//=============================================================================
		// ЏeЊ•‘•’…‚Н‰рЏњ
		//=============================================================================
    	if( ROProjectileWeapon(Weapon) != None )
    	{
    		if( ROProjectileWeapon(Weapon).IsInState('AttachingBayonet')
    		||	ROProjectileWeapon(Weapon).IsInState('DetachingBayonet'))
    		{
				bBlindPosition = false;
	     		SideBlind = false;
	   		}
    	}
	}

	//=============================================================================
	// Џг•ыЊь‚Мѓuѓ‰ѓCѓ“ѓhѓtѓ@ѓCѓA
	//=============================================================================
	if( bBlindPosition )
	{
    	//=============================================================================
		// ѓsѓXѓgѓ‹‚И‚зЌ¶rЏkЏ¬
		//=============================================================================
    	if( ROPistolWeapon(Weapon) != None )
    	{
    		ROPistolWeapon(Weapon).SetBoneScale(0, 0.0, 'Bip01 L UpperArm');
    	}
		
		//=============================================================================
		// ЏгЊА‚Ь‚Е‘«‚µ‚Д‚ў‚­
		//=============================================================================
		if( BlindAmountV < 30.0 )
		{
			BlindAmountV += 100.0 * deltatime;
		}
	}
	else
	{

		//=============================================================================
		// ‰єЊА‚Ь‚Е€ш‚ў‚Д‚ў‚­
		//=============================================================================
		if( BlindAmountV > 0.0 )
		{
			BlindAmountV -= 100.0 * deltatime;
		}
		
		if( BlindAmountV <= 0 )
		{
	    	//=============================================================================
			// ѓsѓXѓgѓ‹‚И‚зЌ¶rЉg‘е
			//=============================================================================
	    	if( ROPistolWeapon(Weapon) != None )
	    	{
	    		ROPistolWeapon(Weapon).SetBoneScale(0, 1.0, 'Bip01 L UpperArm');
	    	}
		}
	}	
	
	
	//=============================================================================
	// ‰Ў‚Мѓuѓ‰ѓCѓ“ѓhѓtѓ@ѓCѓA
	//=============================================================================
	if( ( bLeanLeft || bLeanRight ) && SideBlind )
	{
		//=============================================================================
		// ЏгЊА‚Ь‚Е‘«‚µ‚Д‚ў‚­
		//=============================================================================
		if( BlindAmountH < 30.0 )
		{
			BlindAmountH += 100.0 * deltatime;
		}
	}
	else
	{
		//=============================================================================
		// ‰єЊА‚Ь‚Е€ш‚ў‚Д‚ў‚­
		//=============================================================================
		if( BlindAmountH > 0.0 )
		{
			BlindAmountH -= 100.0 * deltatime;
		}
	}
	

}

//-----------------------------------------------------------------------------
// EndCrouchЃ@Њo‚Б‚Ѕ‚Ж‚«‚Й‚а‰рЏњ
//-----------------------------------------------------------------------------
event EndCrouch(float HeightAdjust)
{
	bBlindPosition = false;
	super.EndCrouch(HeightAdjust);
}

//-----------------------------------------------------------------------------
// StartCrouch - ‚µ‚б‚Є‚Э‚МЋћ‚Й‰рЏњ
//-----------------------------------------------------------------------------
event StartCrouch(float HeightAdjust)
{
	bBlindPosition = false;
	super.StartCrouch(HeightAdjust);
}
//-----------------------------------------------------------------------------
// StartProne - •љ‚№‚МЋћ‚Й‰рЏњ
//-----------------------------------------------------------------------------
event StartProne(float HeightAdjust)
{
	bBlindPosition = false;
	super.StartProne(HeightAdjust);
}
	
//-----------------------------------------------------------------------------
// PlayStartCrawling - Plays the anim going into prone
//-----------------------------------------------------------------------------
simulated function PlayStartCrawling()
{
	local name Anim;
	local float AnimTimer;

	if (bIsCrouched)
	{
		if (WeaponAttachment != None)
			Anim = WeaponAttachment.PA_CrouchToProneAnim;
		else
			Anim = CrouchToProneAnim;

		PlayOwnedSound(CrouchToProneSound, SLOT_Interact, 1.0,, 10);
	}
	else
	{
		if (WeaponAttachment != None)
			Anim = WeaponAttachment.PA_StandToProneAnim;
		else
			Anim = StandToProneAnim;

		PlayOwnedSound(StandToProneSound, SLOT_Interact, 1.0,, 10);
	}

    AnimTimer = GetAnimDuration(Anim, 1.0);

    // Have the server finish the prone transition state slightly before the client (fixes some client/server sync issues)
	if( Level.NetMode == NM_DedicatedServer || (Level.NetMode == NM_ListenServer && !Instigator.IsLocallyControlled()))
		SetTimer(AnimTimer - (AnimTimer * 0.1),false);
	else
		SetTimer(AnimTimer,false);

	if (bIsIdle && !bIsCrouched)
	{
		PlayAnim(Anim,1.0,0.0,0);
	}
	else
	{
		PlayAnim(Anim,1.0,0.0,0);
		WeaponState = GS_Ready;
	}
}
	
//=============================================================================
// •\Ћ¦€К’uѓIѓtѓZѓbѓgЊџЏo
//=============================================================================
simulated function vector CalcDrawOffset(inventory Inv)
{
	local vector DrawOffset;
	
	if ( Controller == None )
		return (Inv.PlayerViewOffset >> Rotation) + BaseEyeHeight * vect(0,0,1);

	DrawOffset = ((0.9/Weapon.DisplayFOV * 100 * ModifiedPlayerViewOffset(Inv)) >> GetViewRotation() );
	// Added these for proneing and leaning
	DrawOffset.Z += EyePosition().Z;
	DrawOffset.X += EyePosition().X;
	DrawOffset.Y += EyePosition().Y;

    DrawOffset += WeaponBob(Inv.BobDamping);
    DrawOffset += CameraShake();
		
	
	
	//=============================================================================
	// ѓuѓ‰ѓCѓ“ѓhѓtѓ@ѓCѓAѓIѓtѓZѓbѓg
	//=============================================================================
	DrawOffset += (MaxBlindPositionU * BlindAmountV) >> GetViewRotation();
	if( LeanAmount < 0)
	{
		DrawOffset += (MaxBlindPositionL * BlindAmountH) >> GetViewRotation();
	}
	else if( LeanAmount > 0)
	{
		DrawOffset += (MaxBlindPositionR * BlindAmountH) >> GetViewRotation();
	}
	
	return DrawOffset;
}
	
//=============================================================================
// ѓЉЃ[ѓ“Ћћ‚МѓtѓЉЃ[ѓGѓCѓЂ’Іђ®
//=============================================================================
simulated function LeanRight()
{
	if ( TraceWall(16384, 64) || bLeaningLeft || bIsSprinting )
	{
	
		//=============================================================================
		// ѓЉЃ[ѓ“ѓuѓ‰ѓCѓ“ѓhѓtѓ@ѓCѓA‚М”Н€Н–Я‚·
		//=============================================================================
		if ( ROPlayer(Controller) != none)
		{
			ROPlayer(Controller).FreeAimMaxYawLimit=2000;
			ROPlayer(Controller).FreeAimMinYawLimit=63535;
		}
		bLeanRight=false;
		return;
	}

	if ( !bLeanLeft )
		bLeanRight=true;

	//=============================================================================
	// ѓЉЃ[ѓ“ѓuѓ‰ѓCѓ“ѓhѓtѓ@ѓCѓA‚М”Н€Н‚Н‚№‚Ь‚ў
	//=============================================================================
	if ( ROPlayer(Controller) != none)
	{
		ROPlayer(Controller).FreeAimMaxYawLimit=500;
		ROPlayer(Controller).FreeAimMinYawLimit=65535;
		
	}
}
simulated function LeanLeft()
{
	if ( TraceWall(-16384, 64) || bLeaningRight || bIsSprinting )
	{
	
		//=============================================================================
		// ѓЉЃ[ѓ“ѓuѓ‰ѓCѓ“ѓhѓtѓ@ѓCѓA‚М”Н€Н–Я‚·
		//=============================================================================
		if ( ROPlayer(Controller) != none)
		{
			ROPlayer(Controller).FreeAimMaxYawLimit=2000;
			ROPlayer(Controller).FreeAimMinYawLimit=63535;
		}
		bLeanLeft=false;
		return;
	}

	if ( !bLeanRight )
		bLeanLeft=true;
	
	//=============================================================================
	// ѓЉЃ[ѓ“ѓuѓ‰ѓCѓ“ѓhѓtѓ@ѓCѓA‚М”Н€Н‚Н‚№‚Ь‚ў
	//=============================================================================
	if ( ROPlayer(Controller) != none)
	{
		ROPlayer(Controller).FreeAimMaxYawLimit=0;
		ROPlayer(Controller).FreeAimMinYawLimit=65035;
	}
}
simulated function LeanRightReleased()
{
	//=============================================================================
	// ѓЉЃ[ѓ“ѓuѓ‰ѓCѓ“ѓhѓtѓ@ѓCѓA‚М”Н€Н–Я‚·
	//=============================================================================
	if ( ROPlayer(Controller) != none)
	{
		ROPlayer(Controller).FreeAimMaxYawLimit=2000;
		ROPlayer(Controller).FreeAimMinYawLimit=63535;
	}
	bLeanRight=false;
}
simulated function LeanLeftReleased()
{
	//=============================================================================
	// ѓЉЃ[ѓ“ѓuѓ‰ѓCѓ“ѓhѓtѓ@ѓCѓA‚М”Н€Н–Я‚·
	//=============================================================================
	if ( ROPlayer(Controller) != none)
	{
		ROPlayer(Controller).FreeAimMaxYawLimit=2000;
		ROPlayer(Controller).FreeAimMinYawLimit=63535;
	}
	bLeanLeft=false;
}

//=============================================================================
// •ђЉн•ПЌXЋћ‚Нѓuѓ‰ѓCѓ“ѓhѓtѓ@ѓCѓA‰рЏњ
//=============================================================================
simulated function ChangedWeapon()
{
	Super.ChangedWeapon();
	bBlindPosition = false;

}
	
	

////////////////////////////////////////////////////////////////////////
// “ЛЊ‚ѓ{ѓCѓX
////////////////////////////////////////////////////////////////////////
simulated function ChargeVoice()
{
	local ROPlayerReplicationInfo RPR;
	local bool bRidioVoice;
	
	//=============================================================================
	// €к•”‚МЋћ‚Нђ¶ђє
	//=============================================================================
	bRidioVoice = true;
	if( ROPassengerPawn(DrivenVehicle) != None
	||	RMFWheeledVehicle(DrivenVehicle) != None
	||	BA64GunPawn(DrivenVehicle) != None
	||	Sdkfz251GunPawn(DrivenVehicle) != None
	||	UniCarrierGunPawn(DrivenVehicle) != None
	||	M1937CannonPawn(DrivenVehicle) != None)
	{
		bRidioVoice = false;
	}
	
	
	// ѓXѓ^ѓ~ѓiѓ`ѓFѓbѓN
	if(Stamina > ChargeStaminaLimit)
	{
		// ROPlayerReplicationInfoЋж“ѕ
		if(DrivenVehicle != None)
		{
			RPR = ROPlayerReplicationInfo(DrivenVehicle.Controller.PlayerReplicationInfo);
		}
		else
		{
			RPR = ROPlayerReplicationInfo(Controller.PlayerReplicationInfo);
   		}

		// ђ•ЋІ
    	if(GetTeamNum() == AXIS_TEAM_INDEX)
    	{
    		
    		// •Є‘а’·‚МЋћ‚Мђє
	    	if(RPR.RoleInfo.bIsLeader)
	    	{
	    		if( DrivenVehicle == None || !bRidioVoice )
	    		{
					PlaySound(sound'RMFSounds.Charge.german_charge_order', SLOT_None,2.0,,,1.0,false);
				}
				else
				{
					PlaySound(sound'RMFSounds.german_vehicle_charge_order', SLOT_None,1.0,,80,1.0,false);
				}
			}
    		// ’КЏн•є‚Мђє
			else
			{
	    		if( DrivenVehicle == None || !bRidioVoice)
	    		{
					PlaySound(sound'RMFSounds.Charge.german_charge', SLOT_None,2.0,,,1.0,false);
				}
				else
				{
					PlaySound(sound'RMFSounds.german_vehicle_charge', SLOT_None,1.0,,80,1.0,false);
				}
			}
		}
		else
		{
    		// •Є‘а’·‚МЋћ‚Мђє
	    	if( RPR.RoleInfo.bIsLeader)
	    	{
	    		if( DrivenVehicle == None || !bRidioVoice)
	    		{
					PlaySound(sound'RMFSounds.Charge.russian_charge_order', SLOT_None,2.0,,,1.0,false);
				}
				else
				{
					PlaySound(sound'RMFSounds.russian_vehicle_charge_order', SLOT_None,1.0,,80,1.0,false);
				}
			}
    		// ’КЏн•є‚Мђє
			else
			{
	    		if( DrivenVehicle == None || !bRidioVoice)
	    		{
					PlaySound(sound'RMFSounds.Charge.russian_charge', SLOT_None,2.0,,,1.0,false);
				}
				else
				{
					PlaySound(sound'RMFSounds.russian_vehicle_charge', SLOT_None,1.0,,80,1.0,false);
				}
			}
		}
  		
    	// ѓXѓ^ѓ~ѓiЊёЏ­
	    Stamina = FMax(Stamina - 2.0, 0.0);
	    
	    // ѓNѓ‰ѓCѓAѓ“ѓgѓXѓ^ѓ~ѓiЌXђV
		if (Role == ROLE_Authority)
		{
			ClientForceStaminaUpdate(Stamina);
		}
		
	}
}	
////////////////////////////////////////////////////////////////////////
// “J
////////////////////////////////////////////////////////////////////////
simulated function Whistle()
{
	local ROPlayerReplicationInfo RPR;
	
	// ѓXѓ^ѓ~ѓiѓ`ѓFѓbѓN
	if(Stamina > WhisleStaminaLimit)
	{
		// ROPlayerReplicationInfoЋж“ѕ
		if(DrivenVehicle != None)
		{
			RPR = ROPlayerReplicationInfo(DrivenVehicle.Controller.PlayerReplicationInfo);
		}
		else
		{
			RPR = ROPlayerReplicationInfo(Controller.PlayerReplicationInfo);
   		}

		// •Є‘а’·‚М‚Э
	  	if(RPR.RoleInfo.bIsLeader)
	  	{
	  		// “J‚М‰№
			PlaySound(sound'RMFSounds.Whistle.ChargeWhistle', SLOT_None,1.0,,,1.0,false);

	    	// ѓXѓ^ѓ~ѓiЊёЏ­
		    Stamina = FMax(Stamina - 2.0, 0.0);
		    // ѓNѓ‰ѓCѓAѓ“ѓgѓXѓ^ѓ~ѓiЌXђV
			if (Role == ROLE_Authority)
			{
				ClientForceStaminaUpdate(Stamina);
			}
	  		
	  		
//	  		// Bot‚Мѓ{ѓCѓX
//			ForEach AllActors( class'RMFBot', RB)
//			{
//				if( RB.GetTeamNum() == GetTeamNum())
//				RB.SetTimer(FRand() * 0.15, false);
//			}	  		
	  		
		}
	}

}
	
	

defaultproperties
{
     ChargeStaminaLimit=12
     WhisleStaminaLimit=16
     GerFaceName(0)="RMFSkins_Heads.ger_heads.ger_face01"
     GerFaceName(1)="RMFSkins_Heads.ger_heads.ger_face02"
     GerFaceName(2)="RMFSkins_Heads.ger_heads.ger_face03"
     GerFaceName(3)="RMFSkins_Heads.ger_heads.ger_face04"
     GerFaceName(4)="RMFSkins_Heads.ger_heads.ger_face05"
     GerFaceName(5)="RMFSkins_Heads.ger_heads.ger_face06"
     GerFaceName(6)="RMFSkins_Heads.ger_heads.ger_face07"
     GerFaceName(7)="RMFSkins_Heads.ger_heads.ger_face08"
     GerFaceName(8)="RMFSkins_Heads.ger_heads.ger_face09"
     GerFaceName(9)="RMFSkins_Heads.ger_heads.ger_face10"
     GerFaceName(10)="RMFSkins_Heads.ger_heads.ger_face11"
     GerFaceName(11)="RMFSkins_Heads.ger_heads.ger_face12"
     GerFaceName(12)="RMFSkins_Heads.ger_heads.ger_face13"
     GerFaceName(13)="RMFSkins_Heads.ger_heads.ger_face14"
     GerFaceName(14)="RMFSkins_Heads.ger_heads.ger_face15"
     RusFaceName(0)="RMFSkins_Heads.rus_heads.rus_face01"
     RusFaceName(1)="RMFSkins_Heads.rus_heads.rus_face02"
     RusFaceName(2)="RMFSkins_Heads.rus_heads.rus_face03"
     RusFaceName(3)="RMFSkins_Heads.rus_heads.rus_face04"
     RusFaceName(4)="RMFSkins_Heads.rus_heads.rus_face05"
     RusFaceName(5)="RMFSkins_Heads.rus_heads.rus_face06"
     RusFaceName(6)="RMFSkins_Heads.rus_heads.rus_face07"
     RusFaceName(7)="RMFSkins_Heads.rus_heads.rus_face08"
     RusFaceName(8)="RMFSkins_Heads.rus_heads.rus_face09"
     RusFaceName(9)="RMFSkins_Heads.rus_heads.rus_face10"
     RusFaceName(10)="RMFSkins_Heads.rus_heads.rus_face11"
     RusFaceName(11)="RMFSkins_Heads.rus_heads.rus_face12"
     RusFaceName(12)="RMFSkins_Heads.rus_heads.rus_face13"
     RusFaceName(13)="RMFSkins_Heads.rus_heads.rus_face14"
     RusFaceName(14)="RMFSkins_Heads.rus_heads.rus_face15"
     MaxBlindPositionU=(X=-1.600000,Y=-0.500000,Z=2.000000)
     MaxBlindPositionL=(Y=-1.400000)
     MaxBlindPositionR=(Y=1.400000)
     Species=Class'RMFEngine.RMFSPECIES_Human'
     RagdollLifeSpan=100.000000
     RagInvInertia=5.500000
     RagDeathVel=80.000000
     RagShootStrength=2.000000
     RagSpinScale=1.000000
     RagMaxSpinAmount=50.000000
     RagGravScale=0.800000
     RagImpactSound=SoundGroup'RMFSounds.Ragdoll.BodyImpact'
     SprintAccelRate=423.500000
     GroundSpeed=242.000000
     WaterSpeed=121.000000
     AirSpeed=84.699997
     LadderSpeed=90.750000
     AccelRate=363.000000
     JumpZ=380.600006
     ControllerClass=Class'RMFEngine.RMFBot'
     WalkAnims(0)="stand_walkFhip_satchel"
     WalkAnims(1)="stand_walkBhip_satchel"
     WalkAnims(2)="stand_walkLhip_satchel"
     WalkAnims(3)="stand_walkRhip_satchel"
     WalkAnims(4)="stand_walkFLhip_satchel"
     WalkAnims(5)="stand_walkFRhip_satchel"
     WalkAnims(6)="stand_walkBLhip_satchel"
     WalkAnims(7)="stand_walkBRhip_satchel"
     AirAnims(0)="jumpF_mid_satchel"
     AirAnims(1)="jumpB_mid_satchel"
     AirAnims(2)="jumpL_mid_satchel"
     AirAnims(3)="jumpR_mid_satchel"
     TakeoffAnims(0)="jumpF_takeoff_satchel"
     TakeoffAnims(1)="jumpB_takeoff_satchel"
     TakeoffAnims(2)="jumpL_takeoff_satchel"
     TakeoffAnims(3)="jumpR_takeoff_satchel"
     LandAnims(0)="jumpF_land_satchel"
     LandAnims(1)="jumpB_land_satchel"
     LandAnims(2)="jumpL_land_satchel"
     LandAnims(3)="jumpR_land_satchel"
     DodgeAnims(0)="jumpF_mid_satchel"
     DodgeAnims(1)="jumpB_mid_satchel"
     DodgeAnims(2)="jumpL_mid_satchel"
     DodgeAnims(3)="jumpR_mid_satchel"
     AirStillAnim="jump_mid_satchel"
     TakeoffStillAnim="jump_takeoff_satchel"
     Begin Object Class=KarmaParamsSkel Name=PawnKParams
         KConvulseSpacing=(Max=2.200000)
         KLinearDamping=0.150000
         KAngularDamping=0.050000
         KBuoyancy=1.000000
         KStartEnabled=True
         KVelDropBelowThreshold=50.000000
         bHighDetailOnly=False
         KFriction=2.000000
         KRestitution=0.200000
         KImpactThreshold=85.000000
     End Object
     KParams=KarmaParamsSkel'RMFEngine.RMFPawn.PawnKParams'

}
