//===================================================================
// RMFTankCannon
//===================================================================
class RMFTankCannon extends ROEngine.ROTankCannon
      abstract;

var   config		float		DispersionMult;                        //test
var   config		bool		bGunFireDebug;
var() config		bool		bGunsightSettingMode;

var int MainAmmoChargeMod[3];						// ’e–ò”(ƒvƒ‰ƒCƒ}ƒŠEƒZƒJƒ“ƒ_ƒŠEƒT[ƒh)
var()	int	InitialThirdlyAmmo;						// ƒT[ƒh‰Šú’e–ò
var()   class<Projectile>   ThirdlyProjectileClass; // ‚R‚Â‚ß

var()	bool	HasDelayFusePrimary;						// 
var()	bool	HasDelayFuseSecondary;						// 
var()	bool	HasDelayFuseThirdly;						// 

var() float FireBulr;
var() float AltFireBulr;


var	  bool 	CurrentFuseType; 	// HE‚ÌMŠÇƒ^ƒCƒv
//var	  bool 	PendingFuseType; 	// HE‚ÌMŠÇƒ^ƒCƒv(ŽŸ‚Ì)




//============================
// ’e‚Ì”ò‹——£’²®—p
//============================
struct RangePoint
{
	var() int           	Range;     			// Meter distance for this range setting
	var() float           	RangeValue;     	// The adjustment value for this range setting
};
var array<RangePoint>	TestRanges; 		// Ý’è—pƒƒJƒjƒJƒ‹ƒŒƒ“ƒW

//============================
// ƒŒƒ“ƒWŽæ“¾
//============================
simulated function int GetPitchForRange(int RangeIndex)
{
	return TestRanges[RangeIndex].RangeValue;
}
//============================
// ƒŒƒ“ƒWÝ’è
//============================
simulated function SetPitchForRange(int RangeIndex, int RangeValue)
{
	local int i;
	for( i = RangeIndex; i < TestRanges.Length; i++)
	{
		TestRanges[i].RangeValue = RangeValue;
	}
}

    
////////////////////////////////////////////////////////////////////////
// replication
////////////////////////////////////////////////////////////////////////
replication
{

	// ‘æŽO’e–ò—p
	reliable if (bNetDirty && bNetOwner && Role == ROLE_Authority)
		MainAmmoChargeMod, CurrentFuseType;//, PendingFuseType;
	
}

////////////////////////////////////////////////////////////////////////
// HE‚ÌMŠÇÝ’èƒNƒ‰ƒCƒAƒ“ƒg‘¤
////////////////////////////////////////////////////////////////////////
function ToggleFuseType()
{
	local PlayerController P;

	//============================
	// MŠÇÝ’è‚ª‰Â”\H
	//============================
//	if( HasDelayFuse() )
//	{
//		//============================
//		// MŠÇ‚ÌØ‚è‘Ö‚¦
//		//============================
//		if( PendingFuseType )
//			PendingFuseType = false;
//		else
//			PendingFuseType = true;
//		
//		if (Instigator != None)
//		{
//			P = PlayerController(Instigator.Controller);
//			if (P != None )
//			{
//				ROPlayer(P).ClientPlaySound(sound'ROMenuSounds.msfxMouseClick',false,,SLOT_Interface);
//			}
//		}
//
//	}
//	else
//	{
//		//============================
//		// Ø‚è‘Ö‚¦‚ª‚Å‚«‚È‚¯‚ê‚Î–³‚µ
//		//============================
//		PendingFuseType = false;
//	}
	
	//============================
	// ‘•“U‘O‚È‚ç‘¦Ø‚è‘Ö‚¦
	//============================
	if( HasDelayFuse() && ( CannonReloadState == CR_Empty || CannonReloadState == CR_Waiting ) )
	{
		if( CurrentFuseType )
			CurrentFuseType = false;
		else
			CurrentFuseType = true;
		
		if (Instigator != None)
		{
			P = PlayerController(Instigator.Controller);
			if (P != None )
			{
				ROPlayer(P).ClientPlaySound(sound'ROMenuSounds.msfxMouseClick',false,,SLOT_Interface);
			}
		}
	}
//	Level.Game.Broadcast(self, "PendingFuseType="$PendingFuseType$"CurrentFuseType="$CurrentFuseType);
}

//===================================================================
// ”­ŽË€”õ
//===================================================================
simulated function bool HasDelayFuse()
{
	if (ProjectileClass == PrimaryProjectileClass)
		return HasDelayFusePrimary;
	else if (ProjectileClass == SecondaryProjectileClass)
		return HasDelayFuseSecondary;
	else if (ProjectileClass == ThirdlyProjectileClass)
		return HasDelayFuseThirdly;

	return false;

}



////////////////////////////////////////////////////////////////////////
// ƒT[ƒo[‘¤ƒŠƒ[ƒh
////////////////////////////////////////////////////////////////////////
function ServerManualReload()
{
    if(Role != ROLE_Authority)
        return;

    if( CannonReloadState == CR_Waiting )
    {
		//============================
		// MŠÇƒ^ƒCƒv•Û‘¶
		//============================
//		CurrentFuseType = PendingFuseType;
    	
        //If the user wants a different ammo type, switch on reload
        if( PendingProjectileClass != none && ProjectileClass != PendingProjectileClass )
    	{
	   	    ProjectileClass = PendingProjectileClass;
    	}

	   	//Tell the client to start reloading
	   	ClientSetReloadState(CR_Empty);

	    //Start the reloading process
        CannonReloadState = CR_Empty;
        SetTimer(0.01, false);
    }
}


////////////////////////////////////////////////////////////////////////
// GetRoundsDescription
////////////////////////////////////////////////////////////////////////
simulated function int GetRoundsDescription(out array<string> descriptions)
{
    local int i;
    descriptions.length = 0;
    for (i = 0; i < ProjectileDescriptions.length; i++)
        descriptions[i] = ProjectileDescriptions[i];

    if (ProjectileClass == PrimaryProjectileClass)
        return 0;
    else if (ProjectileClass == SecondaryProjectileClass)
        return 1;
    else if (ProjectileClass == ThirdlyProjectileClass)
        return 2;
    else
        return 3;
}

////////////////////////////////////////////////////////////////////////
// GetPendingRoundIndex
////////////////////////////////////////////////////////////////////////
simulated function int GetPendingRoundIndex()
{
    if( PendingProjectileClass == none )
    {
	    if (ProjectileClass == PrimaryProjectileClass)
	        return 0;
	    else if (ProjectileClass == SecondaryProjectileClass)
	        return 1;
	    else if (ProjectileClass == ThirdlyProjectileClass)
	        return 2;
	    else
	        return 3;
    }
    else
    {
		if (PendingProjectileClass == PrimaryProjectileClass)
		    return 0;
		else if (PendingProjectileClass == SecondaryProjectileClass)
		    return 1;
		else if (PendingProjectileClass == ThirdlyProjectileClass)
		    return 2;
		else
		    return 3;
    }
}

////////////////////////////////////////////////////////////////////////
// ToggleRoundType
////////////////////////////////////////////////////////////////////////
function ToggleRoundType()
{
	// ŽŸ‚Ì’e–ò‚ðÝ’è‚µ‚Ä‚¨‚­
	if( PendingProjectileClass == PrimaryProjectileClass || PendingProjectileClass == none )
	{
		if( !HasAmmo(1) && !HasAmmo(2) )
			return;

		if( HasAmmo(1) )
			PendingProjectileClass = SecondaryProjectileClass;
		else if( HasAmmo(2) )
			PendingProjectileClass = ThirdlyProjectileClass;
			
	}
	else if( PendingProjectileClass == SecondaryProjectileClass )
	{
		if( !HasAmmo(2) && !HasAmmo(0) )
			return;

		if( HasAmmo(2) )
			PendingProjectileClass = ThirdlyProjectileClass;
		else if( HasAmmo(0) )
			PendingProjectileClass = PrimaryProjectileClass;
	}
	else
	{
		if( !HasAmmo(0) && !HasAmmo(1) )
			return;

		if( HasAmmo(0) )
			PendingProjectileClass = PrimaryProjectileClass;
		else if( HasAmmo(1) )
			PendingProjectileClass = SecondaryProjectileClass;
	}
	
	// ’e‘q‚ª‹ó‚È‚ç’¼‚É•ÏX
	if( CannonReloadState == CR_Empty || CannonReloadState == CR_Waiting)
	{
		if( ProjectileClass == PrimaryProjectileClass )
		{
			if( HasAmmo(1) )
				ProjectileClass = SecondaryProjectileClass;
			else if( HasAmmo(2) )
			   	ProjectileClass = ThirdlyProjectileClass;
				
		}
		else if(ProjectileClass == SecondaryProjectileClass )
		{
			if( HasAmmo(2) )
				ProjectileClass = ThirdlyProjectileClass;
			else if( HasAmmo(0) )
			   	ProjectileClass = PrimaryProjectileClass;
		}
		else if(ProjectileClass == ThirdlyProjectileClass )
		{
			if( HasAmmo(0) )
				ProjectileClass = PrimaryProjectileClass;
			else if( HasAmmo(1) )
			   	ProjectileClass = SecondaryProjectileClass;
		}
	}
}


////////////////////////////////////////////////////////////////////////
// H
////////////////////////////////////////////////////////////////////////
simulated event OwnerEffects()
{
	// Stop the firing effects it we shouldn't be able to fire
	if( (Role < ROLE_Authority) && !ReadyToFire(bIsAltFire) )
	{
		VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(bIsAltFire);
		return;
	}

    if (!bIsRepeatingFF)
	{
		if (bIsAltFire)
			ClientPlayForceFeedback( AltFireForce );
		else
			ClientPlayForceFeedback( FireForce );
	}
    ShakeView(bIsAltFire);

	if( Level.NetMode == NM_Standalone && bIsAltFire)
	{
		if (AmbientEffectEmitter != None)
			AmbientEffectEmitter.SetEmitterStatus(true);
	}

	if (Role < ROLE_Authority)
	{
		if (bIsAltFire)
			FireCountdown = AltFireInterval;
		/*else
			FireCountdown = FireInterval;*/

		if( !bIsAltFire )
		{
			if( Instigator != none && Instigator.Controller != none && ROPlayer(Instigator.Controller) != none &&
                ROPlayer(Instigator.Controller).bManualTankShellReloading == true )
            {
			    CannonReloadState = CR_Waiting;
			}
			else
			{
	            CannonReloadState = CR_Empty;
	            SetTimer(0.01, false);
	        }

			bClientCanFireCannon = false;
		}

		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

        FlashMuzzleFlash(bIsAltFire);

		if (AmbientEffectEmitter != None && bIsAltFire)
			AmbientEffectEmitter.SetEmitterStatus(true);

        if (bIsAltFire)
		{
            if( !bAmbientAltFireSound )
		    	PlaySound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
		    else
		    {
			    SoundVolume = AltFireSoundVolume;
	            SoundRadius = AltFireSoundRadius;
				AmbientSoundScaling = AltFireSoundScaling;
		    }
        }
		else if (!bAmbientFireSound)
        {
            PlaySound(CannonFireSound[Rand(3)], SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
        }
	}
}

////////////////////////////////////////////////////////////////////////
// ”­ŽËH
////////////////////////////////////////////////////////////////////////
event bool AttemptFire(Controller C, bool bAltFire)
{
  	if(Role != ROLE_Authority || bForceCenterAim)
		return False;

	if ( (!bAltFire && CannonReloadState == CR_ReadyToFire && bClientCanFireCannon) || (bAltFire && FireCountdown <= 0))
	{
		CalcWeaponFire(bAltFire);
		if (bCorrectAim)
			WeaponFireRotation = AdjustAim(bAltFire);
		if( bAltFire )
		{
			//============================
			// ”ò‹——£Ý’è‚Ì
			//============================
			if(bGunsightSettingMode)
			{
				WeaponFireRotation.Pitch += GetPitchForRange(CurrentRangeIndex);	// AB
			}
			else
			{
				WeaponFireRotation.Pitch += PrimaryProjectileClass.static.GetPitchForRange(RangeSettings[CurrentRangeIndex]);	// AB
			}
			
			
			if( AltFireSpread > 0 )
			{
				WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*AltFireSpread);
			}
		}
		else
		{
			 if (Spread > 0)
				WeaponFireRotation = rotator(vector(WeaponFireRotation) + VRand()*FRand()*Spread);
		}

        DualFireOffset *= -1;

		Instigator.MakeNoise(1.0);
		if (bAltFire)
		{
			if( !ConsumeAmmo(3) )
			{
				VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(bAltFire);
				HandleReload();
				return false;
			}

			FireCountdown = AltFireInterval;
			AltFire(C);

			if( AltAmmoCharge < 1 )
				HandleReload();
		}
		else
		{
		    //FireCountdown = FireInterval;
			if( bMultipleRoundTypes )
			{
				if (ProjectileClass == PrimaryProjectileClass)
				{
					if( !ConsumeAmmo(0) )
					{
						VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(bAltFire);
						return false;
					}
					else
					{
						if( !HasAmmo(0) && HasAmmo(1) )
						{
							ToggleRoundType();
						}
					}
			    }
			    else if (ProjectileClass == SecondaryProjectileClass)
			    {
					if( !ConsumeAmmo(1) )
					{
						VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(bAltFire);
						return false;
					}
					else
					{
						if( !HasAmmo(1) && HasAmmo(2) )
						{
							ToggleRoundType();
						}
					}
			    }
			    else if (ProjectileClass == ThirdlyProjectileClass)
			    {
					if( !ConsumeAmmo(2) )
					{
						VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(bAltFire);
						return false;
					}
					else
					{
						if( !HasAmmo(2) && HasAmmo(0) )
						{
							ToggleRoundType();
						}
					}
			    }
			}
			else if( !ConsumeAmmo(0) )
			{
				VehicleWeaponPawn(Owner).ClientVehicleCeaseFire(bAltFire);
				return false;
			}

			if( Instigator != none && Instigator.Controller != none && ROPlayer(Instigator.Controller) != none &&
                ROPlayer(Instigator.Controller).bManualTankShellReloading == true )
            {
			    CannonReloadState = CR_Waiting;
			}
			else
			{
	            CannonReloadState = CR_Empty;
	            SetTimer(0.01, false);
	        }

	        bClientCanFireCannon = false;
		    Fire(C);
		}
		AimLockReleaseTime = Level.TimeSeconds + FireCountdown * FireIntervalAimLock;

	    return True;
	}

	return False;
}

////////////////////////////////////////////////////////////////////////
// –C’eì¬
////////////////////////////////////////////////////////////////////////
function Projectile SpawnProjectile(class<Projectile> ProjClass, bool bAltFire)
{
    local Projectile P;
    local VehicleWeaponPawn WeaponPawn;
    local vector StartLocation, HitLocation, HitNormal, Extent;
    local rotator FireRot;

	FireRot = WeaponFireRotation;

	// used only for Human players. Lets cannons with non centered aim points have a different aiming location
	if( Instigator != none && Instigator.IsHumanControlled() )
	{
		FireRot.Pitch += AddedPitch;
	}
	
	
	//============================
	// ”ò‹——£Ý’è‚ÌŽž‚Í–C‚ÌŠp“x–³Ž‹
	//============================
	if(bGunsightSettingMode)
	{
  		FireRot.Pitch -= rotator(vector(CurrentAim) >> Rotation).Pitch;
	}

	if( !bAltFire )
	{
		//============================
		// ”ò‹——£Ý’è‚Ì
		//============================
		if(bGunsightSettingMode)
		{
			FireRot.Pitch += GetPitchForRange(CurrentRangeIndex);
		}
		else
		{
			//============================
			// ˆê•”‚Ì•û‚ÍŠp“x–³Ž‹
			//============================
			if( !Owner.IsA('BT7CannonPawn')
			&& !Owner.IsA('Stug3CannonPawn') 
			&& !Owner.IsA('M1937CannonPawn')
			&& !Owner.IsA('SU76CannonPawn') )
			{
				FireRot.Pitch += ProjClass.static.GetPitchForRange(RangeSettings[CurrentRangeIndex]);
			}
		}
	}
	
    if( bCannonShellDebugging )
		log("GetPitchForRange for "$CurrentRangeIndex$" = "$ProjClass.static.GetPitchForRange(RangeSettings[CurrentRangeIndex]));

    if (bDoOffsetTrace)
    {
       	Extent = ProjClass.default.CollisionRadius * vect(1,1,0);
        Extent.Z = ProjClass.default.CollisionHeight;
       	WeaponPawn = VehicleWeaponPawn(Owner);
    	if (WeaponPawn != None && WeaponPawn.VehicleBase != None)
    	{
    		if (!WeaponPawn.VehicleBase.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (WeaponPawn.VehicleBase.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
	else
	{
		if (!Owner.TraceThisActor(HitLocation, HitNormal, WeaponFireLocation, WeaponFireLocation + vector(WeaponFireRotation) * (Owner.CollisionRadius * 1.5), Extent))
			StartLocation = HitLocation;
		else
			StartLocation = WeaponFireLocation + vector(WeaponFireRotation) * (ProjClass.default.CollisionRadius * 1.1);
	}
    }
    else
    	StartLocation = WeaponFireLocation;

	if( bCannonShellDebugging )
		Trace(TraceHitLocation, HitNormal, WeaponFireLocation + 65355 * Vector(WeaponFireRotation), WeaponFireLocation, false);

    P = spawn(ProjClass, none, , StartLocation, FireRot); //self

	
	//============================
	// MŠÇƒ^ƒCƒvÝ’è
	//============================
	if( !bAltFire && CurrentFuseType && HasDelayFuse() )
	{
	    if (P != None)
	    {
	    	RMFBullet(P).bDelayFuse = true;
	    }
	}
	
   //swap to the next round type after firing
    if( PendingProjectileClass != none && ProjClass == ProjectileClass && ProjectileClass != PendingProjectileClass )
	{
		ProjectileClass = PendingProjectileClass;
	}
    //log("WeaponFireRotation = "$WeaponFireRotation);

    if (P != None)
    {
        if (bInheritVelocity)
            P.Velocity = Instigator.Velocity;

        FlashMuzzleFlash(bAltFire);

        // Play firing noise
        if (bAltFire)
        {
            if (bAmbientAltFireSound)
            {
                AmbientSound = AltFireSoundClass;
                SoundVolume = AltFireSoundVolume;
                SoundRadius = AltFireSoundRadius;
                AmbientSoundScaling = AltFireSoundScaling;
            }
            else
                PlayOwnedSound(AltFireSoundClass, SLOT_None, FireSoundVolume/255.0,, AltFireSoundRadius,, false);
        }
        else
        {
            if (bAmbientFireSound)
                AmbientSound = FireSoundClass;
            else
            {
                PlayOwnedSound(CannonFireSound[Rand(3)], SLOT_None, FireSoundVolume/255.0,, FireSoundRadius,, false);
            }
        }
    }

    return P;
}


//===================================================================
// ƒVƒFƒCƒN
//===================================================================
simulated function ShakeView(bool bWasAltFire)
{
	local PlayerController P;

	if (Instigator == None)
		return;

	P = PlayerController(Instigator.Controller);
	if (P != None )
	{
		if( bWasAltFire )
		{
			P.WeaponShakeView(AltShakeRotMag, AltShakeRotRate, AltShakeRotTime, AltShakeOffsetMag, AltShakeOffsetRate, AltShakeOffsetTime);
			// ”­ŽËƒuƒ‰[
    		if( ROPlayer( P ) != None )
    		{
				if( RMFPlayer( P ).bUseFireBlur )
				{
			    	ROPlayer( P ).AddBlur( AltFireBulr, 0.1 );
			    }
			}
		}
		else
		{
			P.WeaponShakeView(ShakeRotMag, ShakeRotRate, ShakeRotTime, ShakeOffsetMag, ShakeOffsetRate, ShakeOffsetTime);
			
			// ”­ŽËƒuƒ‰[
    		if( ROPlayer( P ) != None )
    		{
				if( RMFPlayer( P ).bUseFireBlur )
				{
			    	ROPlayer( P ).AddBlur( FireBulr, 0.1 );
				}
			}
		}
	}
}

//===================================================================
// ŽËŒ‚‚â‚ß
//===================================================================
function CeaseFire(Controller C, bool bWasAltFire)
{
	super(ROVehicleWeapon).CeaseFire(C, bWasAltFire);

	if( bWasAltFire && !HasAmmo(3) )
		HandleReload();
}

//===================================================================
// Žc’e”Žæ“¾
//===================================================================
simulated function bool HasAmmo(int Mode)
{
	switch(Mode)
	{
		case 0:
			return (MainAmmoChargeMod[0] > 0);
			break;
		case 1:
			return (MainAmmoChargeMod[1] > 0);
			break;
		case 2:
			return (MainAmmoChargeMod[2] > 0);
			break;
		case 3:
			return (AltAmmoCharge > 0);
			break;
		default:
			return false;
	}

	return false;
}

//===================================================================
// ”­ŽË€”õ
//===================================================================
simulated function bool ReadyToFire(bool bAltFire)
{
	local int Mode;
	
	if(	bAltFire )
		Mode = 3;
	else if (ProjectileClass == PrimaryProjectileClass)
		Mode = 0;
	else if (ProjectileClass == SecondaryProjectileClass)
		Mode = 1;
	else if (ProjectileClass == ThirdlyProjectileClass)
		Mode = 2;

	if( HasAmmo(Mode) )
		return true;

	return false;
}

//===================================================================
// ƒvƒ‰ƒCƒ}ƒŠŽc’e”
//===================================================================
simulated function int PrimaryAmmoCount()
{
	if( bMultipleRoundTypes )
	{
		if (ProjectileClass == PrimaryProjectileClass)
	        return MainAmmoChargeMod[0];
	    else if (ProjectileClass == SecondaryProjectileClass)
	        return MainAmmoChargeMod[1];
	    else if (ProjectileClass == ThirdlyProjectileClass)
	        return MainAmmoChargeMod[2];
	}
	else
	{
		return MainAmmoChargeMod[0];
	}
}

//===================================================================
// ’eÁ”ï
//===================================================================
simulated function bool ConsumeAmmo(int Mode)
{
	if( !HasAmmo(Mode) )
		return false;

	switch(Mode)
	{
		case 0:
			MainAmmoChargeMod[0]--;
			return true;
		case 1:
			MainAmmoChargeMod[1]--;
			return true;
		case 2:
			MainAmmoChargeMod[2]--;
			return true;
		case 3:
			AltAmmoCharge--;
			return true;
		default:
			return false;
	}

	return false;
}

//===================================================================
// ƒfƒoƒbƒO•\Ž¦
//===================================================================
function DrawDebugHitPoint()
{
	local int i;
	local coords C;
	local DebugSphere DS;
	local vector Org;
	
//	Level.Game.Broadcast(self, "BoneNum:"$default.VehHitpoints.Length);
	
	for( i = 0; i < default.VehHitpoints.Length; i++ )
	{	
		C = GetBoneCoords( default.VehHitpoints[i].PointBone );
		Org = C.Origin + (default.VehHitpoints[i].PointOffset >> Rotation);
		DS = Spawn(class'RMFEngine.DebugSphere', self, ,Org, );
		DrawStayingDebugLine( Org, Org + (Vector(Rotation)*default.VehHitpoints[i].PointRadius), 255, 0, 0);
		//DS.AttachToBone( self, default.VehHitpoints[i].PointBone );
	}
	
}


//===================================================================
// ƒŒƒ“ƒWƒf[ƒ^o—Í
//===================================================================
simulated function OutSightData()
{
	local int i;

	log("*************************" );
	log("***"$ProjectileClass$"***" );
	for( i = 0; i < TestRanges.Length; i++)
	{
		log("MechanicalRanges("$i$")=(Range="$RangeSettings[i]$",RangeValue="$GetPitchForRange(i)$")" );
		ROPlayer(Instigator.Controller).ClientMessage("MechanicalRanges("$i$")=(Range="$RangeSettings[i]$",RangeValue="$GetPitchForRange(i)$")" );
		
	}
	log("*************************" );
	
}

//===================================================================
// ƒŒƒ“ƒWƒf[ƒ^Ý’èƒ‚[ƒh
//===================================================================
simulated function SightSetMode()
{
	if( bGunsightSettingMode )
	{
		if( Instigator != none && Instigator.Controller != none && ROPlayer(Instigator.Controller) != none )
			ROPlayer(Instigator.Controller).ClientMessage("SetMode OFF");
		bGunsightSettingMode = false;
	}
	else
	{
		if( Instigator != none && Instigator.Controller != none && ROPlayer(Instigator.Controller) != none )
			ROPlayer(Instigator.Controller).ClientMessage("SetMode ON");
		bGunsightSettingMode = true;
	}
//	ROPlayer(Instigator.Controller).ClientMessage("Rotation.Pitch="$rotator(vector(CurrentAim) >> Rotation).Pitch-AddedPitch$")");
}
//===================================================================
// ’e–ò•â[
//===================================================================
simulated function FillAmmo()
{
    if( PendingProjectileClass != none && ProjectileClass != PendingProjectileClass )
   	    ProjectileClass = PendingProjectileClass;
	if(Role == ROLE_Authority)
	{
		bClientCanFireCannon = true;
	}
	CannonReloadState = CR_ReadyToFire;
}

//===================================================================
// ƒŒƒ“ƒW’²®
//===================================================================
function IncrementRange()
{
	if(bGunsightSettingMode && (Level.NetMode == NM_Standalone) )
	{
		IncreaseAddedPitch();
		GiveInitialAmmo();
		FillAmmo();
	}
	else 
	{
		Super.IncrementRange();	
	}
}
function DecrementRange()
{
	if(bGunsightSettingMode && (Level.NetMode == NM_Standalone))
	{
		DecreaseAddedPitch();
		GiveInitialAmmo();
		FillAmmo();
	}
	else 
	{
		Super.DecrementRange();	
	}
}

//===================================================================
// ƒŒƒ“ƒW’²®
//===================================================================
Function IncreaseAddedPitch()
{
//	local int MechanicalRangesValue, Correction;
	local int value;
	
	value = GetPitchForRange(CurrentRangeIndex);
	value += 4;
	ROPlayer(Instigator.Controller).ClientMessage("Range= "$RangeSettings[CurrentRangeIndex]$" m value ="$value);
	SetPitchForRange(CurrentRangeIndex, value);
}

Function DecreaseAddedPitch()
{
	local int value;
	
	value = GetPitchForRange(CurrentRangeIndex);
	value -= 4;
	ROPlayer(Instigator.Controller).ClientMessage("Range= "$RangeSettings[CurrentRangeIndex]$" m value ="$value);
	SetPitchForRange(CurrentRangeIndex, value);
}



//===================================================================
// ’e–ò‰Šú‰»
//===================================================================
function bool GiveInitialAmmo()
{
	local bool bDidResupply;

	// If we don't need any ammo return false
	if( MainAmmoCharge[0] != InitialPrimaryAmmo || MainAmmoCharge[1] != InitialSecondaryAmmo || MainAmmoCharge[2] != InitialThirdlyAmmo
		|| AltAmmoCharge != InitialAltAmmo || NumAltMags != default.NumAltMags )
	{
		bDidResupply = true;
	}

	MainAmmoChargeMod[0] = InitialPrimaryAmmo;
	MainAmmoChargeMod[1] = InitialSecondaryAmmo;
	MainAmmoChargeMod[2] = InitialThirdlyAmmo;
	AltAmmoCharge = InitialAltAmmo;
	NumAltMags = default.NumAltMags;

	CurrentFuseType = false;
	
	return bDidResupply;
}

defaultproperties
{
     TestRanges(1)=(Range=200)
     TestRanges(2)=(Range=400)
     TestRanges(3)=(Range=500)
     TestRanges(4)=(Range=600)
     TestRanges(5)=(Range=700)
     TestRanges(6)=(Range=800)
     TestRanges(7)=(Range=900)
     TestRanges(8)=(Range=1000)
     TestRanges(9)=(Range=1100)
     TestRanges(10)=(Range=1200)
     TestRanges(11)=(Range=1300)
     TestRanges(12)=(Range=1400)
     TestRanges(13)=(Range=1500)
     TestRanges(14)=(Range=1600)
     TestRanges(15)=(Range=1700)
     TestRanges(16)=(Range=1800)
     TestRanges(17)=(Range=1900)
     TestRanges(18)=(Range=2000)
     TestRanges(19)=(Range=2100)
     TestRanges(20)=(Range=2200)
     TestRanges(21)=(Range=2300)
     TestRanges(22)=(Range=2400)
     TestRanges(23)=(Range=2500)
     TestRanges(24)=(Range=2600)
     TestRanges(25)=(Range=2700)
     TestRanges(26)=(Range=2800)
     TestRanges(27)=(Range=2900)
     TestRanges(28)=(Range=3000)
     TestRanges(29)=(Range=3200)
     TestRanges(30)=(Range=3400)
     TestRanges(31)=(Range=3600)
     TestRanges(32)=(Range=3800)
     TestRanges(33)=(Range=4000)
     TestRanges(34)=(Range=4200)
     TestRanges(35)=(Range=4400)
     TestRanges(36)=(Range=4600)
     TestRanges(37)=(Range=4800)
     TestRanges(38)=(Range=5000)
     AltFireSpread=0.005000
}
