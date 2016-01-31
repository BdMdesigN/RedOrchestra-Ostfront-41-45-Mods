//-----------------------------------------------------------
// RMFWheeledVehicle
//-----------------------------------------------------------
class RMFWheeledVehicle extends ROEngine.ROWheeledVehicle 
abstract;

////////////////////////////////////////////////////////////////////////
// •Ï”
////////////////////////////////////////////////////////////////////////
// ŽÔ—¼‚ª‹ß‚­‚ð’Ê‚Á‚½Žž‚ÌU“®
var vector 	ModShakeMag;
var vector 	ModShakeRate;
var float  	ModShakeTime;
var float	ShakeRadius;

// ‘•b’l
var		int			FrontArmorFactor;		// ŽÔ‘Ì³–Ê
var		int			RearArmorFactor;		// ŽÔ‘Ì”w–Ê
var		int			SideArmorFactor;		// ŽÔ‘Ì‘¤–Ê
var		int			ThreatFrontArmorFactor;	// –C“ƒ³–Ê
var		int			ThreatRearArmorFactor;	// –C“ƒ”w–Ê
var		int			ThreatSideArmorFactor;	// ŽÔ‘Ì‘¤–Ê

// ƒVƒ…ƒ‹ƒcƒFƒ“
var     bool        bHasThreatAddedSideArmor;	// –C“ƒ‘¤–Ê
var     bool        bHasThreatAddedRearArmor;	// –C“ƒ”w–Ê
var     bool        bHasAddedSideArmor;			// ŽÔ‘Ì‘¤–Ê

// ƒTƒEƒ“ƒh
var()   	sound               LeftTreadSound;    // Sound for the left tread squeaking
var()   	sound               RightTreadSound;   // Sound for the right tread squeaking
var     	ROSoundAttachment   LeftTreadSoundAttach;
var     	ROSoundAttachment   RightTreadSoundAttach;
var     	float               MotionSoundVolume;
var()   float                 MaxPitchSpeed;
var()   	name                LeftTrackSoundBone;
var()   	name                RightTrackSoundBone;

// ƒVƒ…ƒ‹ƒcƒFƒ“ƒ_ƒ[ƒWŒyŒ¸
//var		float		APDamageScale;
//var		float		HEATDamageScale;
//var		float		HEDamageScale;
//var		float		ATDamageScale;

//var		float		ThreatOffcetLength;		// –C“ƒ‚ ‚½‚è”»’è‚ÌƒIƒtƒZƒbƒg

// ‘¤–Ê”»’è—pH
var() float FrontLeftAngle, FrontRightAngle, RearRightAngle, RearLeftAngle;

// —š‘ÑŠÖŒW(ŽÔ—Ö)
var 	float		TreadHitMinAngle;			// Any hits bigger than this angle are considered tread hits
var     bool		bLeftTrackDamaged;  // The left track has been damaged
var     bool		bRightTrackDamaged; // The left track has been damaged

var		float 	AngleTable[11];						// Šp“x‚É‚æ‚éŒ¸Š—¦

var	name ThreatBoneName; // –C“ƒ‰ñ“]ƒx[ƒX–¼

//=============================================================================
// GetPenetrationProbability
//=============================================================================
simulated function float GetPenetrationProbability( float AOI )
{
    local float index;

    index = (AOI/90)*12;

	if( index <= 1)			return 0.0;
	else if ( index <= 2)	return AngleTable[0];
	else if ( index <= 3)	return AngleTable[1];
	else if ( index <= 4)	return AngleTable[2];
	else if ( index <= 5)	return AngleTable[3];
	else if ( index <= 6)	return AngleTable[4];
	else if ( index <= 7)	return AngleTable[5];
	else if ( index <= 8)	return AngleTable[6];
	else if ( index <= 9)	return AngleTable[7];
	else if ( index <= 10)	return AngleTable[8];
	else if ( index <= 11)	return AngleTable[9];
	else if ( index <= 12)	return AngleTable[10];
	else 					return 1.0;
}

//=============================================================================
// replication
//=============================================================================
replication
{
	reliable if( bNetDirty && Role==ROLE_Authority /*&& bDisableThrottle*/ )
        	bRightTrackDamaged, bLeftTrackDamaged;
}

////////////////////////////////////////////////////////////////////////
// PostBeginPlay
////////////////////////////////////////////////////////////////////////
simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if ( Level.NetMode != NM_DedicatedServer )
	{
		if (  LeftTreadSoundAttach == none )
		{
			LeftTreadSoundAttach = Spawn(class 'ROSoundAttachment');
			LeftTreadSoundAttach.AmbientSound = LeftTreadSound;
			AttachToBone(LeftTreadSoundAttach, LeftTrackSoundBone);
		}

		if (  RightTreadSoundAttach == none )
		{
			RightTreadSoundAttach = Spawn(class 'ROSoundAttachment');
			RightTreadSoundAttach.AmbientSound = RightTreadSound;
			AttachToBone(RightTreadSoundAttach, RightTrackSoundBone );
		}
	}
}


////////////////////////////////////////////////////////////////////////
// UpdateMovementSound
////////////////////////////////////////////////////////////////////////
simulated function UpdateMovementSound()
{
    if (  LeftTreadSoundAttach != none && !bLeftTrackDamaged )
    {
       LeftTreadSoundAttach.SoundVolume= MotionSoundVolume * 1.00;
    }

    if (  RightTreadSoundAttach != none && !bRightTrackDamaged )
    {
       RightTreadSoundAttach.SoundVolume= MotionSoundVolume * 1.00;
    }
}

////////////////////////////////////////////////////////////////////////
// Destroyed
////////////////////////////////////////////////////////////////////////
simulated function Destroyed()
{

	if( LeftTreadSoundAttach != none )
	    LeftTreadSoundAttach.Destroy();
	if( RightTreadSoundAttach != none )
	    RightTreadSoundAttach.Destroy();

	super.Destroyed();
}

////////////////////////////////////////////////////////////////////////
// Destroyed
////////////////////////////////////////////////////////////////////////
function DriverLeft()
{
    // Not moving, so no motion sound
    MotionSoundVolume=0.0;
    UpdateMovementSound();

    Super.DriverLeft();
}

////////////////////////////////////////////////////////////////////////
// Tick
////////////////////////////////////////////////////////////////////////
simulated function Tick(float DeltaTime)
{
	local PlayerController PC;
	local float Dist, Scale;
	
	Super.Tick( DeltaTime );

	if(bDriving)
	{
		// ƒT[ƒoˆÈŠO
		if ( Level.NetMode != NM_DedicatedServer )
		{
			// ƒvƒŒƒCƒ„[ƒRƒ“ƒgƒ[ƒ‰Žæ“¾
			PC = Level.GetLocalPlayerController();
			
			// •à‚¢‚Ä‚¢‚éƒvƒŒƒCƒ„[‚Ì‚ÝB
			if ( PC != None && PC.ViewTarget != None && !PC.ViewTarget.IsA('ROVehicle') && !PC.ViewTarget.IsA('ROVehicleWeaponPawn') && !PC.ViewTarget.IsA('ROBot') )
			{
				// ‹——£‚ð‹‚ß‚é
				Dist = VSize( Location - PC.ViewTarget.Location );
				
				// ”ÍˆÍ“à‚È‚çU“®‚³‚¹‚é
				if ( Dist < ShakeRadius )
				{
					scale = ( ShakeRadius - Dist ) / ShakeRadius;
	                scale *= 0.8;
					scale *= FMin( 1.0, ( VSize( Velocity ) / 100.0 ) );
					
					PC.ShakeView( ModShakeMag*Scale, ModShakeRate, ModShakeTime, ModShakeMag*Scale, ModShakeRate, ModShakeTime );
				}
			}
		}
	}
}

////////////////////////////////////////////////////////////////////////
// GetLocalString
////////////////////////////////////////////////////////////////////////
static function string GetLocalString(
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2
	)
{
	return Default.TouchMessage$default.VehicleNameString;
}

////////////////////////////////////////////////////////////////////////
// æ‚ê‚È‚¢ƒƒbƒZ[ƒW
////////////////////////////////////////////////////////////////////////
function DenyEntry( Pawn P, int MessageNum )
{
	P.ReceiveLocalizedMessage(class'RMFVehicleMessage', MessageNum);
}

function Vehicle FindEntryVehicle(Pawn P)
{
	local int x;
	local float Dist;
	local bool CanEnter;
	CanEnter = false;
	
	//============================
	// ‚±‚±‚©‚çæ‚ê‚È‚¢ƒƒbƒZ‚¶
	//============================
	Dist = VSize(P.Location - (Location + (EntryPosition >> Rotation)));
	if (Dist < EntryRadius)
		CanEnter = true;
	for (x = 0; x < WeaponPawns.length; x++)
	{
    	Dist = VSize(P.Location - (WeaponPawns[x].Location + (WeaponPawns[x].EntryPosition >> Rotation)));
		if (Dist < WeaponPawns[x].EntryRadius)
			CanEnter = true;
	}
	
	if( !CanEnter )
	{
		DenyEntry( P, 2 );
	}
	
	return Super.FindEntryVehicle(P);
}


////////////////////////////////////////////////////////////////////////
// IsDisabled
////////////////////////////////////////////////////////////////////////
simulated function bool IsDisabled()
{
	return (Health <= 0);//(EngineHealth <= 0);
}

////////////////////////////////////////////////////////////////////////
// TakeDamage
////////////////////////////////////////////////////////////////////////
function TakeDamage(int Damage, Pawn instigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)
{
	local vector LocDir, HitDir;
	local float HitAngle,Side, InAngle;
    local vector X,Y,Z;

    local int i,j;
//    local float VehicleDamageMod;
    local int HitPointDamage;
	local int InstigatorTeam;
	local controller InstigatorController;
	local float ScaledDamage;
	local bool bHit;
	
	local float TrackDamage;
	local float InAngleDegrees;
	//============================
	// ’l‰Šú‰»
	//============================
	bHit = false;
	

	//============================
	// Ž©ŽEƒƒbƒZ[ƒW’²®
	//============================
    if (DamageType == class'Suicided')
    {
	    DamageType = Class'ROSuicided';
	    Super(ROVehicle).TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	}
	else if (DamageType == class'ROSuicided')
	{
		super(ROVehicle).TakeDamage(Damage, instigatedBy, Hitlocation, Momentum, damageType);
	}

	// H
	if(instigatedBy == self)
		return;

	// H
	if( !bDriverAlreadyEntered )
	{
		if ( InstigatedBy != None )
			InstigatorController = instigatedBy.Controller;

		if ( InstigatorController == None )
		{
			if ( DamageType.default.bDelayedDamage )
				InstigatorController = DelayedDamageInstigatorController;
		}

		if ( InstigatorController != None )
		{
			InstigatorTeam = InstigatorController.GetTeamNum();

			if ( (GetTeamNum() != 255) && (InstigatorTeam != 255) )
			{
				if ( GetTeamNum() == InstigatorTeam )
				{
					return;
				}
			}
		}
	}

	//============================
    // ŽÔ—¼ƒ_ƒ[ƒWƒ^ƒCƒv‚Ö•ÏŠ·
	//============================
//	if (DamageType != none)
//	{
//	   if(class<ROWeaponDamageType>(DamageType) != none)
//       		VehicleDamageMod = class<ROWeaponDamageType>(DamageType).default.TankDamageModifier;
//       else if(class<ROVehicleDamageType>(DamageType) != none)
//	   		VehicleDamageMod = class<ROVehicleDamageType>(DamageType).default.TankDamageModifier;
 //   }

	//============================
    // ƒ_ƒ[ƒWŒ¸Š
	//============================
	if ( DamageType == class'PanzerFaustImpactDamType' )
	{
		ScaledDamage = Damage * 3;
//		Level.Game.Broadcast(self, "Damage="$Damage);
	}	
	else if ( DamageType == class'HECannonShellDamageSmall' || DamageType == class'HECannonShellDamage'  || DamageType == class'HECannonShellDamageLarge' || DamageType == class'PanzerFaustDamType' )
	{
		//============================
	    // HE‚È‚çƒ_ƒ[ƒWŒƒŒ¸
		//============================
		ScaledDamage = Damage * 0.05;
	}	
	else
	{
		//============================
		// ŠÑ’ÊŒã‚ÌˆÐ—Í
		//============================
		ScaledDamage = Damage * 0.3;
	//	Spawn(class'RMFEngine.DebugSphere', self, ,Hitlocation, );
	//	DrawStayingDebugLine( HitLocation, HitLocation + (Normal(Momentum)*ScaledDamage), 0, 0, 255);
	}
	
	
	//============================
	// ƒTƒbƒ`ƒFƒ‹‚Ìƒ_ƒ[ƒW‚¶‚á‚È‚¢
	//============================
	if( DamageType != class'ROSatchelDamType'
		&& DamageType != class'HECannonShellDamageSmall'
		&& DamageType != class'HECannonShellDamage'
		&& DamageType != class'HECannonShellDamageLarge'
		&& DamageType != class'PanzerFaustDamType')
	{
		//============================
		// “à•”‚Ìæˆõƒqƒbƒg
		//============================
		for( i = 0; i < VehHitpoints.Length; i++ )
		{
			//============================
			// ”‚«‚¾‚µ‚Ä‚È‚¢ƒgƒR‚¾‚¯
			//============================
			if( !VehHitpoints[i].bPenetrationPoint )
			{
				//============================
				// ŠÑ’Ê‚µ‚Äæˆõ‚Ö‚Ìƒ_ƒ[ƒW(ƒhƒ‰ƒCƒo[)
				//============================
				if ( VehHitpoints[i].HitPointType == HP_Normal )
				{
					//Level.Game.Broadcast(self, "PenetrateDamageDriver="$ScaledDamage);
					if ( IsPointShot( Hitlocation, Momentum, 1.0, i, ScaledDamage ) )
					{
						//Level.Game.Broadcast(self, "HP_Driver");
						if( Driver != none )
						{
							RMFPawn(Driver).TakeDamage(ScaledDamage, instigatedBy, Hitlocation, Momentum, damageType);
							break;
						}
					}
				}
				
				//============================
				// ŠÑ’Ê‚µ‚Äæˆõ‚Ö‚Ìƒ_ƒ[ƒW(æˆõ)
				//============================
				if ( VehHitpoints[i].HitPointType == HP_Driver )
				{
					//============================
					// ‚»‚Ì‘¼‚Ìæˆõ‚Ö‚Ìƒ_ƒ[ƒW
					//============================
					for( j = 0; j < PassengerWeapons.Length; j++ )
					{
						if ( IsPointShot( Hitlocation, Momentum, 1.0, i, ScaledDamage ) )
						{
							if( VehHitpoints[i].PointBone == PassengerWeapons[j].WeaponBone )
							{
								//============================
								// WeaponPawns‚ª‚ ‚é‚È‚ç
								//============================
								if( WeaponPawns[j] != none )
								{
									//Level.Game.Broadcast(self, "PenetrateDamageWeaponPawns="$ScaledDamage);
									//Level.Game.Broadcast(self, "HP_Passenger");
									if( WeaponPawns[j].Driver != none  )
									{
										RMFPawn(WeaponPawns[j].Driver).TakeDamage(ScaledDamage, instigatedBy, Hitlocation, Momentum, damageType);
										break;
									}
								}
							}
						}
					}
				}
				//============================
				// íŽÔ“à‚ÌÝ”õ‚Ö‚Ìƒ_ƒ[ƒW
				//============================
				else if ( IsPointShot(Hitlocation,Momentum, 1.0, i, ScaledDamage) )
				{
					//============================
					// ƒqƒbƒgêŠ‚Ìƒ_ƒ[ƒWÝ’è
					//============================
			    	HitPointDamage=ScaledDamage;
					//Level.Game.Broadcast(self, "Damage="$Damage);
					
					//============================
					// ƒ_ƒ[ƒW”{—¦
					//============================
					HitPointDamage *= VehHitpoints[i].DamageMultiplier;
		            //log("We hit "$GetEnum(enum'EPawnHitPointType',VehHitpoints[i].HitPointType));
					
					//============================
					// ƒGƒ“ƒWƒ“ƒ_ƒ[ƒW
					//============================
					if ( VehHitpoints[i].HitPointType == HP_Engine )
					{
						///Level.Game.Broadcast(self, "HP_Engine");
						DamageEngine(HitPointDamage, instigatedBy, Hitlocation, Momentum, damageType);
						bHit = true;
					}
					//============================
					// ’e–òŒÉƒ_ƒ[ƒW
					//============================
					else if ( VehHitpoints[i].HitPointType == HP_AmmoStore )
					{
						//Level.Game.Broadcast(self, "HP_AmmoStore");
						ScaledDamage *= VehHitpoints[i].DamageMultiplier;
						bHit = true;
					}

				}			
			
			}
			

		}
	}
	
	//============================
	// APHE
	//============================
	if( DamageType == class'PenetrateExplosionDamage'  )
	{

		//============================
		// ƒhƒ‰ƒCƒo[‚Ö‚Ìƒ_ƒ[ƒW
		//============================
		if( Driver != none )
		{
			//Level.Game.Broadcast(WeaponPawns[j].Driver, "Rider"$RMFPawn(WeaponPawns[j].Driver));
			RMFPawn(Driver).TakeDamage(Damage, instigatedBy, Hitlocation + Normal(Momentum) * 80, Momentum, damageType);
		}
		
		//============================
		// ‚»‚Ì‘¼‚Ìæˆõ‚Ö‚Ìƒ_ƒ[ƒW
		//============================
		for( j = 0; j < PassengerWeapons.Length; j++ )
		{
			if( WeaponPawns[j].Driver != none )
			{
				//Level.Game.Broadcast(WeaponPawns[j].Driver, "Rider"$RMFPawn(WeaponPawns[j].Driver));
				RMFPawn(WeaponPawns[j].Driver).TakeDamage(Damage, instigatedBy, Hitlocation + Normal(Momentum), Momentum, damageType);
			}
		}
		
		//============================
		// ƒGƒ“ƒWƒ“ƒ_ƒ[ƒW
		//============================
		DamageEngine(Damage, instigatedBy, Hitlocation + Normal(Momentum), Momentum, damageType);
		ScaledDamage = Damage;
	}	
	
	//============================
	// ŽÔ—ÖE—š‘Ñƒ_ƒ[ƒW
	//============================
	//============================
	// ƒqƒbƒgŠp“x
	//============================
    LocDir = vector(Rotation);
    LocDir.Z = 0;
    HitDir =  Hitlocation - Location;
    HitDir.Z = 0;
    HitAngle = Acos( Normal(LocDir) dot Normal(HitDir));

	//============================
	// ƒ‰ƒWƒAƒ“‚É•ÏŠ·
	//============================
    HitAngle*=57.2957795131;

	//============================
	// ‘¤–Ê”»’è
	//============================
    GetAxes(Rotation,X,Y,Z);
    Side = Y dot HitDir;
    if( side >= 0 )
    {
       HitAngle = 360 + (HitAngle* -1);
    }

	//============================
	// ¶‘¤
	//============================
	if ( HitAngle >= FrontRightAngle && Hitangle < RearRightAngle )
    {
		//============================
		// “üŽËŠp“x
		//============================
    	HitDir = Hitlocation - Location;
	    InAngle= Acos(Normal(HitDir) dot Normal(Z));

		//============================
		// ”j‰ó‚Å‚«‚éŠp“x
		//============================
		if( InAngle > TreadHitMinAngle)
		{
	        InAngleDegrees = Abs(90-((Acos(Normal(-HitDir) dot Normal(-Y))) * 57.2957795131));
//			Level.Game.Broadcast(self, "Angle="$InAngleDegrees);
			TrackDamage = Damage * GetPenetrationProbability( InAngleDegrees );
//			Level.Game.Broadcast(self, "TrackDamage="$TrackDamage$" DamageType="$DamageType);

			//			if (DamageType != none && class<ROWeaponDamageType>(DamageType) != none &&
//				class<ROWeaponDamageType>(DamageType).default.TreadDamageModifier >= 1.0)
			
			//============================
			// ƒ_ƒ[ƒW‚ª400ˆÈã‚È‚ç—š‘Ñ”j‰ó
			//============================
			if( TrackDamage > 400 )
			{
				DamageTrack(true);
				return;
			}
		}
    }
	//============================
	// ‰E‘¤
	//============================
    else if ( HitAngle >= RearLeftAngle && Hitangle < FrontLeftAngle )
    {
		//============================
		// “üŽËŠp“x
		//============================
	    HitDir = Hitlocation - Location;
	    InAngle= Acos(Normal(HitDir) dot Normal(Z));
    	

		//============================
		// ”j‰ó‚Å‚«‚éŠp“x
		//============================
		if( InAngle > TreadHitMinAngle)
		{
	        InAngleDegrees = Abs(90-((Acos(Normal(-HitDir) dot Normal(Y))) * 57.2957795131));
//			Level.Game.Broadcast(self, "Angle="$InAngleDegrees);
			TrackDamage = Damage * GetPenetrationProbability( InAngleDegrees );
//			Level.Game.Broadcast(self, "TrackDamage="$TrackDamage$" DamageType="$DamageType);
//			if (DamageType != none && class<ROWeaponDamageType>(DamageType) != none &&
//				class<ROWeaponDamageType>(DamageType).default.TreadDamageModifier >= 1.0)
			//============================
			// ƒ_ƒ[ƒW‚ª400ˆÈã‚È‚ç—š‘Ñ”j‰ó
			//============================
			if( TrackDamage > 400 )
			{
				DamageTrack(false);
				return;
			}
		}
    }
    
	//else if( DamageType != class'ROSatchelDamType' )
	//    Damage /= 3;

	//Level.Game.Broadcast(self, "Damage"$Damage);
				
	//if( class<ROWeaponDamageType>(DamageType).default.VehicleDamageModifier > 0.25 )
//	if( Damage > 55 )
	
	// ƒqƒbƒgƒ|ƒCƒ“ƒg‚É“–‚½‚ç‚È‚¯‚ê‚Î10•ª‚Ì1
//	if(  !bHit && DamageType != class'ROSatchelDamType' )
//	{
//		Damage /= 3;
//	}
	//============================
	// ƒ}ƒWƒ_ƒ[ƒW
	//============================
    if( ScaledDamage > 0 )
	{
		super(ROVehicle).TakeDamage(ScaledDamage, instigatedBy, Hitlocation, Momentum, damageType);
//		Level.Game.Broadcast(self, "TakeDamage: Damage="$Damage$" DamageType="$DamageType);
	}
}


////////////////////////////////////////////////////////////////////////
// DamageTrack
////////////////////////////////////////////////////////////////////////
function DamageTrack(bool bLeftTrack)
{
	if(bLeftTrack)
	{
//		Level.Game.Broadcast(self, "LeftTrack");
        bLeftTrackDamaged=true;
	}
	else
	{
//		Level.Game.Broadcast(self, "RightTrack");
        bRightTrackDamaged=true;
	}

}

////////////////////////////////////////////////////////////////////////
// HitOpenPoint
////////////////////////////////////////////////////////////////////////
simulated function HitOpenPoint(vector HitLocation, vector HitRay, ROBallisticProjectile BP, class<DamageType> DamageType )
{
	local int i, j;
//	local Actor HitActor;
//	local vector HitLoc, HitNormal;
	
//	Level.Game.Broadcast(self, "HitPenetrationPoint");

	
	
//	Spawn(class'RMFEngine.DebugSphere', self, ,HitLocation, );
//	DrawStayingDebugLine( HitLocation, HitLocation + Normal(HitRay) * 5, 255, 0, 0);
//	HitActor = Trace( HitLoc, HitNormal, HitLocation +  Normal(HitRay) * 50  , HitLocation, true);
//	Level.Game.Broadcast(self, "HitActor="$HitActor);
//	
//	if( Driver != none )
//	{
//		
//		if( RMFPawn(HitActor) != None )
//		{
//			//RMFPawn(Driver).TakeDamage(BP.Damage, BP.Instigator, Hitlocation, BP.MomentumTransfer * Normal(BP.Velocity), DamageType);
//		}
//	}
//	
//	return;
	// ƒNƒŠƒeƒBƒJƒ‹ƒ|ƒCƒ“ƒgƒ`ƒFƒbƒN
	for(i=0; i<VehHitpoints.Length; i++)
	{
		if ( IsPointShot(Hitlocation,300 * HitRay, 1.0, i) )
		{
			if( VehHitpoints[i].HitPointType == HP_Normal )
			{
				//============================
				// Šço‚µ‚Ä‚È‚¢‚Æƒ_ƒƒ|ƒCƒ“ƒgH
				//============================
				if( VehHitpoints[i].bPenetrationPoint )
				{
					//============================
					// Šço‚µ‚Ä‚é
					//============================
					if( DriverPositions[DriverPositionIndex].bExposed )
					{
						//============================
						// ƒ_ƒ[ƒW
						//============================
						if( Driver != none )
						{
							RMFPawn(Driver).TakeDamage(BP.Damage, BP.Instigator, Hitlocation, BP.MomentumTransfer * Normal(BP.Velocity), DamageType);
						}
					}						
				}
				//============================
				// ‘¼‚Í–â“š–³—p
				//============================
//				else
//				{
//					Level.Game.Broadcast(self, "Hit");
//					//============================
//					// ƒ_ƒ[ƒW
//					//============================
//					if( Driver != none )
//					{
//						RMFPawn(Driver).TakeDamage(BP.Damage, BP.Instigator, Hitlocation, BP.MomentumTransfer * Normal(BP.Velocity), DamageType);
//					}
//				}
			}
			else if( VehHitpoints[i].HitPointType == HP_Driver )
			{
				for( j = 0; j < PassengerWeapons.Length; j++ )
				{
					if( VehHitpoints[i].PointBone == PassengerWeapons[j].WeaponBone )
					{
						//============================
						// Šço‚µ‚Ä‚È‚¢‚Æƒ_ƒƒ|ƒCƒ“ƒgH
						//============================
						if( VehHitpoints[i].bPenetrationPoint )
						{
							//============================
							// Šço‚µ‚Ä‚é
							//============================
							if( ROVehicleWeaponPawn(WeaponPawns[j]).DriverPositions[ROVehicleWeaponPawn(WeaponPawns[j]).DriverPositionIndex].bExposed )
							{
								//============================
								// ƒ_ƒ[ƒW
								//============================
								if( WeaponPawns[j].Driver != none )
								{
									RMFPawn(WeaponPawns[j].Driver).TakeDamage(BP.Damage, BP.Instigator, Hitlocation, BP.MomentumTransfer * Normal(BP.Velocity), DamageType);
								}
							}						
						}
						//============================
						// ‘¼‚Í–â“š–³—p
						//============================
//						else
//						{
//							Level.Game.Broadcast(self, "Hit");
//							//============================
//							// ƒ_ƒ[ƒW
//							//============================
//							if( WeaponPawns[j].Driver != none )
//							{
//								RMFPawn(WeaponPawns[j].Driver).TakeDamage(BP.Damage, BP.Instigator, Hitlocation, BP.MomentumTransfer * Normal(BP.Velocity), DamageType);
//							}
//						}
					}
				}
			}

		}
	}

}


////////////////////////////////////////////////////////////////////////
// IsPointShot
////////////////////////////////////////////////////////////////////////
function bool IsPointShot(vector loc, vector ray, float AdditionalScale, int index, optional float CheckDist)
{
	local coords C;
	local vector HeadLoc, B, M, diff;
	local float t, DotMM, Distance;

	if (VehHitpoints[index].PointBone == '')
		return False;

	C = GetBoneCoords(VehHitpoints[index].PointBone);


	HeadLoc = C.Origin + (VehHitpoints[index].PointHeight * VehHitpoints[index].PointScale * AdditionalScale * C.XAxis);
	
	//HeadLoc += VehHitpoints[index].PointOffset;
	
	
	//============================
	// –C“ƒ‚ÌŠp“x
	//============================
	if(default.VehHitpoints[index].PointBone == ThreatBoneName && WeaponPawns.Length > 0 && WeaponPawns[0] != None)
	{
		HeadLoc = HeadLoc + (default.VehHitpoints[index].PointOffset >> Rotation >> rotator(vector(ROVehicleWeapon(WeaponPawns[0].Gun).CurrentAim)));
	}
	else
	{
		HeadLoc = HeadLoc + (VehHitpoints[index].PointOffset >> Rotation);
	}
	
	// Express snipe trace line in terms of B + tM
	B = loc;

	if( CheckDist > 0 )
		M = Normal(ray) * CheckDist;
	else
		M = ray * (2.0 * CollisionHeight + 2.0 * CollisionRadius);

	// Find Point-Line Squared Distance
	diff = HeadLoc - B;
	t = M Dot diff;
	if (t > 0)
	{
		DotMM = M dot M;
		if (t < DotMM)
		{
			t = t / DotMM;
			diff = diff - (t * M);
		}
		else
		{
			t = 1;
			diff -= M;
		}
	}
	else
		t = 0;

	Distance = Sqrt(diff dot diff);

/*
// Hitpoint debugging
	if( VehHitpoints[index].HitPointType==HP_Driver )
	{
	    ClearStayingDebugLines();

	    //DrawStayingDebugLine( loc, (loc + (30 * Normal(C.ZAxis))), 255, 0, 0); // SLOW! Use for debugging only!
	    DrawStayingDebugLine( loc, (loc + M), 0, 255, 0); // SLOW! Use for debugging only!
	}
*/

	return (Distance < (VehHitpoints[index].PointRadius * VehHitpoints[index].PointScale * AdditionalScale));
}

////////////////////////////////////////////////////////////////////////
// ShouldBodyPenetrate
////////////////////////////////////////////////////////////////////////
simulated function bool ShouldBodyPenetrate(vector HitLocation, vector HitRotation, int PenetrationPower, ROBallisticProjectile BP, optional class<DamageType> DamageType)
{
	local vector 	LocDir, HitDir;
	local float		HitAngle,Side,InAngle;
    local vector	X,Y,Z;
    local float		InAngleDegrees;
    local bool		bPenetrate;
    
	local float PPower;	// ŽÀŽ¿ŠÑ’Ê—Í
	
	// ƒNƒŠƒeƒBƒJƒ‹ƒ|ƒCƒ“ƒgƒ`ƒFƒbƒNH
//	if (HitPenetrationPoint(HitLocation, HitRotation))
//	{
//		return true;
//	}
//	Level.Game.Broadcast(self, "==PenetrateCheck==");
	HitOpenPoint(HitLocation, HitRotation, BP,  DamageType );
	
	
	//============================
	// ‰Šú’lÝ’è
	//============================
	bPenetrate	= false;
	
	//============================
	// ƒqƒbƒgˆÊ’u‚ðŒˆ’èH
	//============================
    LocDir = vector(Rotation);
    LocDir.Z = 0;
    HitDir =  Hitlocation - Location;
    HitDir.Z = 0;
    HitAngle = Acos( Normal(LocDir) dot Normal(HitDir));

	//============================
	// ƒ‰ƒWƒAƒ“‚É•ÏŠ·
	//============================
    HitAngle *=57.2957795131;
    GetAxes( Rotation, X, Y, Z );
    Side = Y dot HitDir;

	// H
    if( side >= 0)
    {
       HitAngle = 360 + (HitAngle* -1);
    }
	
	//============================
	// ³–Ê‘•bƒ`ƒFƒbƒN
	//============================
    if ( HitAngle >= FrontLeftAngle || Hitangle < FrontRightAngle )
    {
		//============================
		// i“üŠp“x
		//============================
		InAngle= Acos( Normal( -HitRotation ) dot Normal( X ) );
		InAngleDegrees = 90 - ( InAngle * 57.2957795131 );
//		Level.Game.Broadcast(self, "InAngleDegrees="$InAngleDegrees);

		//============================
		// ŽÀŽ¿ŠÑ’Ê—Í‚ðŽZo
		//============================
		PPower = PenetrationPower * GetPenetrationProbability( InAngleDegrees );
    	
		//============================
		// ‘•b‚ª‚ ‚é‚È‚çƒ`ƒFƒbƒN
		//============================
		if( FrontArmorFactor != 0 )
		{
//			Level.Game.Broadcast(self, "PPower="$PPower$" FrontArmorFactor="$FrontArmorFactor);
			//============================
			// ŠÑ’Ê—Í‚ª‘å‚«‚¯‚ê‚ÎŠÑ’Ê
			//============================
			if( PPower >  FrontArmorFactor )
			{
				bPenetrate = true;
			}
			else
			{
			    bPenetrate = false;
			}
		}
		//============================
		// ‘•b‚ª0‚È‚ç–â“š–³—p‚ÅŠÑ’Ê
		//============================
		else
		{
		    bPenetrate = true;
		}
    }
	//============================
	// ‰E‘¤–Ê‘•bƒ`ƒFƒbƒN
	//============================
    else if ( HitAngle >= FrontRightAngle && Hitangle < RearRightAngle )
    {
		
	    HitDir = Hitlocation - Location;

		//============================
		// i“üŠp“x
		//============================
	   	InAngle= Acos(Normal(-HitRotation) dot Normal(-Y));
        InAngleDegrees = 90-(InAngle * 57.2957795131);

		//============================
		// ŽÀŽ¿ŠÑ’Ê—Í‚ðŽZo
		//============================
		PPower = PenetrationPower * GetPenetrationProbability( InAngleDegrees );

		//============================
		// ‘•b‚ª‚ ‚é‚È‚çƒ`ƒFƒbƒN
		//============================
		if( SideArmorFactor != 0 )
		{
//			Level.Game.Broadcast(self, "PPower="$PPower$" FrontArmorFactor="$FrontArmorFactor);

			//============================
			// ‰¡‚ÌƒVƒ…ƒ‹ƒcƒFƒ“ƒ`ƒFƒbƒN
			//============================
			if( bHasAddedSideArmor )
			{
			//	bPenetrate = HitAddArmor( BP, InAngleDegrees );
			}
			else
			{
				//============================
				// ŠÑ’Ê—Í‚ª‘å‚«‚¯‚ê‚ÎŠÑ’Ê
				//============================
				if( PPower >  SideArmorFactor )
				{
					bPenetrate = true;
				}
				else
				{
				    bPenetrate = false;
				}
			}
		}
		//============================
		// ‘•b‚ª0‚È‚ç–â“š–³—p‚ÅŠÑ’Ê
		//============================
		else
		{
		    bPenetrate = true;
		}
		
    	
		//============================
		// ŽÔ—Ö‚¨‚æ‚Ñ—š‘Ñƒ_ƒ[ƒWƒ`ƒFƒbƒN
		//============================
	    InAngle= Acos(Normal(HitDir) dot Normal(Z));
		if( InAngle > TreadHitMinAngle )
		{
		    bPenetrate = true;
		}

    }
	//============================
	// ”w–Ê‘•bƒ`ƒFƒbƒN
	//============================
    else if ( HitAngle >= RearRightAngle && Hitangle < RearLeftAngle )
    {
		//============================
		// i“üŠp“x
		//============================
		InAngle= Acos(Normal(-HitRotation) dot Normal(-X));
        InAngleDegrees = 90-(InAngle * 57.2957795131);

		//============================
		// ŽÀŽ¿ŠÑ’Ê—Í‚ðŽZo
		//============================
		PPower = PenetrationPower * GetPenetrationProbability( InAngleDegrees );

    	//============================
		// ‘•b‚ª‚ ‚é‚È‚çƒ`ƒFƒbƒN
		//============================
		if( RearArmorFactor != 0 )
		{
//			Level.Game.Broadcast(self, "PPower="$PPower$" FrontArmorFactor="$FrontArmorFactor);

			//============================
			// ŠÑ’Ê—Í‚ª‘å‚«‚¯‚ê‚ÎŠÑ’Ê
			//============================
			if( PPower >  RearArmorFactor )
			{
				bPenetrate = true;
			}
			else
			{
			    bPenetrate = false;
			}
		}
		//============================
		// ‘•b‚ª0‚È‚ç–â“š–³—p‚ÅŠÑ’Ê
		//============================
		else
		{
		    bPenetrate = true;
		}
    }
	//============================
	// ¶‘¤–Ê‘•bƒ`ƒFƒbƒN
	//============================
    else if ( HitAngle >= RearLeftAngle && Hitangle < FrontLeftAngle )
    {
		HitDir = Hitlocation - Location;

		//============================
		// i“üŠp“x
		//============================
	   	InAngle= Acos(Normal(-HitRotation) dot Normal(Y));
        InAngleDegrees = 90-(InAngle * 57.2957795131);

		//============================
		// ŽÀŽ¿ŠÑ’Ê—Í‚ðŽZo
		//============================
		PPower = PenetrationPower * GetPenetrationProbability( InAngleDegrees );

    	//============================
		// ‘•b‚ª‚ ‚é‚È‚çƒ`ƒFƒbƒN
		//============================
		if( SideArmorFactor != 0 )
		{
			//============================
			// ‰¡‚ÌƒVƒ…ƒ‹ƒcƒFƒ“ƒ`ƒFƒbƒN
			//============================
			if( bHasAddedSideArmor )
			{
			//	bPenetrate = HitAddArmor( BP, InAngleDegrees );
			}
			else
			{
				//============================
				// ŠÑ’Ê—Í‚ª‘å‚«‚¯‚ê‚ÎŠÑ’Ê
				//============================
				if( PPower >  SideArmorFactor )
				{
					bPenetrate = true;
				}
				else
				{
				    bPenetrate = false;
				}
			}
		}
		//============================
		// ‘•b‚ª0‚È‚ç–â“š–³—p‚ÅŠÑ’Ê
		//============================
		else
		{
		    bPenetrate = true;
		}

		//============================
		// ŽÔ—Ö‚¨‚æ‚Ñ—š‘Ñƒ_ƒ[ƒWƒ`ƒFƒbƒN
		//============================
	    InAngle= Acos(Normal(HitDir) dot Normal(Z));
		if( InAngle > TreadHitMinAngle )
		{
		    bPenetrate = true;
		}
	}
    else
    {
       bPenetrate = false;
    }
	
    return bPenetrate;
}

////////////////////////////////////////////////////////////////////////
// ShouldThreatPenetrate
////////////////////////////////////////////////////////////////////////
simulated function bool ShouldThreatPenetrate(ROVehicleWeapon RVW, vector HitLocation, vector HitRotation, int PenetrationPower, ROBallisticProjectile BP, optional class<DamageType> DamageType)
{
	local vector LocDir, HitDir;
	local float HitAngle,Side,InAngle;
    local vector X,Y,Z;
    local float InAngleDegrees;
	local Rotator GunRot;
    local bool bPenetrate;
	local float PPower;	// ŽÀŽ¿ŠÑ’Ê—Í
	
	//============================
	// –C“ƒ‚ÌŒü‚«‚ðŽæ“¾
	//============================
	GunRot = rotator(vector(RVW.CurrentAim) >> RVW.Rotation);

	//============================
	// ‰Šú’lÝ’è
	//============================
	bPenetrate = false;
	
	//============================
	// ƒNƒŠƒeƒBƒJƒ‹ƒ|ƒCƒ“ƒgƒ`ƒFƒbƒN
	//============================
//	if (HitPenetrationPoint(HitLocation, HitRotation))
//	{
//		return true;
//	}
	HitOpenPoint(HitLocation, HitRotation, BP,  DamageType );
	
	//============================
	// ‘¤–Êƒ`ƒFƒbƒN
	//============================
    LocDir = vector(GunRot);
    LocDir.Z = 0;
    HitDir =  Hitlocation - RVW.Location;
    HitDir.Z = 0;
    HitAngle = Acos( Normal(LocDir) dot Normal(HitDir));

	//============================
	// ƒ‰ƒWƒAƒ“‚É•ÏŠ·
	//============================
    HitAngle*=57.2957795131;
    GetAxes(GunRot,X,Y,Z);
    Side = Y dot HitDir;

	// H
    if( side >= 0)
    {
       HitAngle = 360 + (HitAngle* -1);
    }
	
	//============================
	// ³–Ê‘•bƒ`ƒFƒbƒN
	//============================
    if ( HitAngle >= FrontLeftAngle || Hitangle < FrontRightAngle )
    {
		//============================
		// i“üŠp“x
		//============================
    	InAngle= Acos(Normal(-HitRotation) dot Normal(X));
		InAngleDegrees = 90-(InAngle * 57.2957795131);

		//============================
		// ŽÀŽ¿ŠÑ’Ê—Í‚ðŽZo
		//============================
		PPower = PenetrationPower * GetPenetrationProbability( InAngleDegrees );
    	
		//============================
		// ‘•b‚ª‚ ‚é‚È‚çƒ`ƒFƒbƒN
		//============================
		if( ThreatFrontArmorFactor != 0 )
		{
//			Level.Game.Broadcast(self, "PPower="$PPower$" FrontArmorFactor="$FrontArmorFactor);
			//============================
			// ŠÑ’Ê—Í‚ª‘å‚«‚¯‚ê‚ÎŠÑ’Ê
			//============================
			if( PPower >  ThreatFrontArmorFactor )
			{
				bPenetrate = true;
			}
			else
			{
			    bPenetrate = false;
			}
		}
		//============================
		// ‘•b‚ª0‚È‚ç–â“š–³—p‚ÅŠÑ’Ê
		//============================
		else
		{
		    bPenetrate = true;
		}

    }
	//============================
	// ‰E‘¤–Ê‘•bƒ`ƒFƒbƒN
	//============================
    else if ( HitAngle >= FrontRightAngle && Hitangle < RearRightAngle )
    {
		
	    HitDir = Hitlocation - RVW.Location;

		//============================
		// i“üŠp“x
		//============================
	    InAngle= Acos(Normal(HitDir) dot Normal(Z));
	   	InAngle= Acos(Normal(-HitRotation) dot Normal(-Y));
        InAngleDegrees = 90-(InAngle * 57.2957795131);

		//============================
		// ŽÀŽ¿ŠÑ’Ê—Í‚ðŽZo
		//============================
		PPower = PenetrationPower * GetPenetrationProbability( InAngleDegrees );

		//============================
		// ‘•b‚ª‚ ‚é‚È‚çƒ`ƒFƒbƒN
		//============================
		if( ThreatSideArmorFactor != 0 )
		{
//			Level.Game.Broadcast(self, "PPower="$PPower$" FrontArmorFactor="$FrontArmorFactor);

			//============================
			// ‰¡‚ÌƒVƒ…ƒ‹ƒcƒFƒ“ƒ`ƒFƒbƒN
			//============================
			if( bHasAddedSideArmor )
			{
			//	bPenetrate = HitAddArmor( BP, InAngleDegrees );
			}
			else
			{
				//============================
				// ŠÑ’Ê—Í‚ª‘å‚«‚¯‚ê‚ÎŠÑ’Ê
				//============================
				if( PPower >  ThreatSideArmorFactor )
				{
					bPenetrate = true;
				}
				else
				{
				    bPenetrate = false;
				}
			}
		}
		//============================
		// ‘•b‚ª0‚È‚ç–â“š–³—p‚ÅŠÑ’Ê
		//============================
		else
		{
		    bPenetrate = true;
		}
		
    }
	//============================
	// ”w–Ê‘•bƒ`ƒFƒbƒN
	//============================
    else if ( HitAngle >= RearRightAngle && Hitangle < RearLeftAngle )
    {
		//============================
		// i“üŠp“x
		//============================
    	InAngle= Acos(Normal(-HitRotation) dot Normal(-X));
        InAngleDegrees = 90-(InAngle * 57.2957795131);

		//============================
		// ŽÀŽ¿ŠÑ’Ê—Í‚ðŽZo
		//============================
		PPower = PenetrationPower * GetPenetrationProbability( InAngleDegrees );

    	//============================
		// ‘•b‚ª‚ ‚é‚È‚çƒ`ƒFƒbƒN
		//============================
		if( ThreatRearArmorFactor != 0 )
		{
//			Level.Game.Broadcast(self, "PPower="$PPower$" FrontArmorFactor="$FrontArmorFactor);

			//============================
			// ”w–Ê‚ÌƒVƒ…ƒ‹ƒcƒFƒ“ƒ`ƒFƒbƒN
			//============================
			if( bHasThreatAddedRearArmor )
			{
			//	bPenetrate = HitAddArmor( BP, InAngleDegrees );
			}
			else
			{
				//============================
				// ŠÑ’Ê—Í‚ª‘å‚«‚¯‚ê‚ÎŠÑ’Ê
				//============================
				if( PPower >  ThreatRearArmorFactor )
				{
					bPenetrate = true;
				}
				else
				{
				    bPenetrate = false;
				}
			}
		}
		//============================
		// ‘•b‚ª0‚È‚ç–â“š–³—p‚ÅŠÑ’Ê
		//============================
		else
		{
		    bPenetrate = true;
		}

    }
	// ¶‘¤–Ê‘•bƒ`ƒFƒbƒN
    else if ( HitAngle >= RearLeftAngle && Hitangle < FrontLeftAngle )
    {
    	HitDir = Hitlocation - RVW.Location;

		//============================
		// i“üŠp“x
		//============================
	    InAngle= Acos(Normal(HitDir) dot Normal(Z));
	   	InAngle= Acos(Normal(-HitRotation) dot Normal(Y));
        InAngleDegrees = 90-(InAngle * 57.2957795131);

		//============================
		// ŽÀŽ¿ŠÑ’Ê—Í‚ðŽZo
		//============================
		PPower = PenetrationPower * GetPenetrationProbability( InAngleDegrees );

    	//============================
		// ‘•b‚ª‚ ‚é‚È‚çƒ`ƒFƒbƒN
		//============================
		if( ThreatSideArmorFactor != 0 )
		{
			//============================
			// ‰¡‚ÌƒVƒ…ƒ‹ƒcƒFƒ“ƒ`ƒFƒbƒN
			//============================
			if( bHasThreatAddedSideArmor )
			{
			//	bPenetrate = HitAddArmor( BP, InAngleDegrees );
			}
			else
			{
				//============================
				// ŠÑ’Ê—Í‚ª‘å‚«‚¯‚ê‚ÎŠÑ’Ê
				//============================
				if( PPower >  ThreatSideArmorFactor )
				{
					bPenetrate = true;
				}
				else
				{
				    bPenetrate = false;
				}
			}
		}
		//============================
		// ‘•b‚ª0‚È‚ç–â“š–³—p‚ÅŠÑ’Ê
		//============================
		else
		{
		    bPenetrate = true;
		}
    }
    else
    {
       log ("We shoulda hit something!!!!");
       bPenetrate = false;
    }
    
//    Level.Game.Broadcast(self, "PenetrationPower="$PenetrationPower);
//    Level.Game.Broadcast(self, "PenetrationProbability="$GetPenetrationProbability(InAngleDegrees));
//    Level.Game.Broadcast(self, "Armor="$Armor);
	
	
    return bPenetrate;
}

/*
////////////////////////////////////////////////////////////////////////
// HitAddArmor
// ƒVƒ…ƒ‹ƒcƒFƒ“‚É‚æ‚éˆÐ—Í’á‰º
////////////////////////////////////////////////////////////////////////
function bool HitAddArmor( ROBallisticProjectile BP, float InAngle )
{
//	BP.instigator.ClientMessage("BP="$BP);
	if (Role == ROLE_Authority)
	{
//		Level.Game.Broadcast(self, "InAngle"$InAngle);

		// ƒpƒ“ƒcƒ@[ƒtƒ@ƒEƒXƒg
		if( BP.IsA('ROZRocketProj') )
		{
			ROZRocketProj(BP).Damage			*= HEATDamageScale;
			ROZRocketProj(BP).ImpactDamage		*= HEATDamageScale;
		}
		// HE’e
		else if( BP.IsA('ROTankCannonShellHE') )
		{
			ROTankCannonShellHE(BP).Damage		*= HEDamageScale;
			ROTankCannonShellHE(BP).ImpactDamage*= HEDamageScale;
		}
		// PTRD
		else if( BP.IsA('PTRDBullet') )
		{
			return false;
			//PTRDBullet(BP).Damage 				*= ATDamageScale;
			//BP.instigator.ClientMessage("Damage="$PTRDBullet(BP).Damage	);
		}
		// AP’e
		else if( BP.IsA('ROTankCannonShell') )
		{
			ROTankCannonShell(BP).Damage		*= APDamageScale;
			ROTankCannonShell(BP).ImpactDamage	*= APDamageScale;
		}
		return true;
	}
	return true;
}
*/



//===================================================================
// ƒfƒoƒbƒO•\Ž¦
//===================================================================
exec function DrawHitPoint()
{
	local int i;
	local coords C;
	local DebugSphere DS;
	local vector Org;
	local float draws;
	
//	Level.Game.Broadcast(self, "BoneNum:"$default.VehHitpoints.Length);
	
	for( i = 0; i < default.VehHitpoints.Length; i++ )
	{	
		C = GetBoneCoords( default.VehHitpoints[i].PointBone );
		
		if(default.VehHitpoints[i].PointBone == ThreatBoneName)
		{
			Org = C.Origin + (default.VehHitpoints[i].PointOffset >> Rotation >> rotator(vector(ROVehicleWeapon(WeaponPawns[0].Gun).CurrentAim)));
		}
		else  
		{
			Org = C.Origin + (default.VehHitpoints[i].PointOffset >> Rotation);
		}
		
		DS = Spawn(class'RMFEngine.DebugSphere', self, ,Org, );
		draws = DS.default.DrawScale * VehHitpoints[i].PointRadius * 0.5;
		DS.SetDrawScale(draws);
		DrawStayingDebugLine( Org, Org + (Vector(Rotation)*default.VehHitpoints[i].PointRadius), 255, 0, 0);
		DS.AttachToBone( self, default.VehHitpoints[i].PointBone );
	}
}

defaultproperties
{
     ModShakeMag=(Z=0.300000)
     ModShakeRate=(Z=20.000000)
     ModShakeTime=0.500000
     ShakeRadius=1000.000000
     FrontArmorFactor=6
     RearArmorFactor=2
     SideArmorFactor=3
     ThreatFrontArmorFactor=6
     ThreatRearArmorFactor=3
     ThreatSideArmorFactor=2
     FrontLeftAngle=333.000000
     FrontRightAngle=28.000000
     RearRightAngle=152.000000
     RearLeftAngle=207.000000
     AngleTable(0)=0.030000
     AngleTable(1)=0.050000
     AngleTable(2)=0.080000
     AngleTable(3)=0.100000
     AngleTable(4)=0.200000
     AngleTable(5)=0.300000
     AngleTable(6)=0.400000
     AngleTable(7)=0.500000
     AngleTable(8)=0.630000
     AngleTable(9)=0.720000
     AngleTable(10)=0.880000
     ThreatBoneName="Turret_placement"
}
