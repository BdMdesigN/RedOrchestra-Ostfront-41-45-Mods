//===================================================================
// ROTankCannonPawn
//===================================================================

class  RMFTankCannonPawn extends ROVehicles.ROTankCannonPawn
       abstract;

////////////////////////////////////////////////////////////////////////
// AB2Ý’è
////////////////////////////////////////////////////////////////////////
var()		bool			bShowCenter;	// shows centering cross in tank sight (edit: and now also lines of required gunsight visible FOV size)
var()		bool			bDebugSightMover; // helps finding correct positions for moving parts of gunsights, not sure how TWI does it
var		int    			GunsightZoomLevels; // number of gunsight positions, 1 for normal optics, 2 for dual-magnification optics
// new variables used in subclasses
var()   float	OverlayCenterScale; // constant used in internal calculations, it's about scaling scope overlays in handy way
var()   float	OverlayCenterSize;  // size of the gunsight overlay, 1.0 means full screen width, 0.5 means half screen width
var()   int	OverlayCorrectionX, OverlayCorrectionY; // scope center correction in pixels, as some overlays are off-center by pixel or two


replication
{
	reliable if( Role<ROLE_Authority )
        ServerToggleFuseType;
}


////////////////////////////////////////////////////////////////////////
// HE‚ÌMŠÇÝ’è
////////////////////////////////////////////////////////////////////////
simulated exec function Deploy()
{
	if( Gun != none && ROTankCannon(Gun) != none )
	{
		ServerToggleFuseType();
	}
}

////////////////////////////////////////////////////////////////////////
// HE‚ÌMŠÇÝ’èŽI‘¤
////////////////////////////////////////////////////////////////////////
function ServerToggleFuseType()
{
	if( Gun != none && ROTankCannon(Gun) != none )
	{
		RMFTankCannon(Gun).ToggleFuseType();
	}
}


////////////////////////////////////////////////////////////////////////
// æ‚èž‚Ý§ŒÀ
////////////////////////////////////////////////////////////////////////
function bool TryToDrive(Pawn P)
{
	
	////////////////////////////////////////////////////////////////////////
	// BOT‚ª•º‰ÈŠÖŒW–³‚µ‚Éæ‚ê‚Ä‚µ‚Ü‚¤‚Ì‚ðC³
	////////////////////////////////////////////////////////////////////////
	if( ROBot(P.Controller) != None )
	{
		if( bMustBeTankCrew && ( !ROBot(P.Controller).GetRoleInfo().bCanBeTankCrew ) )
		{
			return false;
		}
	}

	if (VehicleBase != None)
	{
		if (VehicleBase.NeedsFlip())
		{
			VehicleBase.Flip(vector(P.Rotation), 1);
			return false;
		}

		if (P.GetTeamNum() != Team)
		{
			if (VehicleBase.Driver == None)
				return VehicleBase.TryToDrive(P);

			VehicleLocked(P);
			return false;
		}
	}

	if( bMustBeTankCrew && !ROPlayerReplicationInfo(P.Controller.PlayerReplicationInfo).RoleInfo.bCanBeTankCrew )
	{
		if( P.IsHumanControlled() )
		{
		   DenyEntry( P, 0 );
		   return false;
		}
		else
		{
		   return false;
		}
	}

	return Super(VehicleWeaponPawn).TryToDrive(P);
}


////////////////////////////////////////////////////////////////////////
// ƒƒCƒ“ŽËŒ‚
// ‘oŠá‹¾ƒ|ƒWƒVƒ‡ƒ“‚Ì‚Æ‚«‚Ì”»’è’Ç‰Á DriverPositionIndex >= BinocPositionIndex
////////////////////////////////////////////////////////////////////////
function Fire(optional float F)
{
//	if( DriverPositionIndex >= BinocPositionIndex && ROPlayer(Controller) != none &&
//		ROPlayerReplicationInfo(Controller.PlayerReplicationInfo).RoleInfo.bCanBeTankCommander)
//	{
//		ROPlayer(Controller).ServerSaveArtilleryPosition();
//		return;
//	}
//	else if( DriverPositionIndex >= BinocPositionIndex)
//	{
//		return;
//	}
	if ( Controller != none && ROPlayer(Controller) != none && ROPlayer(Controller).bManualTankShellReloading == true &&
              Gun != none && ROTankCannon(Gun) != none && ROTankCannon(Gun).CannonReloadState == CR_Waiting )
    {
        ROTankCannon(Gun).ServerManualReload();
        return;
    }
	else if (Gun != none && ROTankCannon(Gun) != none && (ROTankCannon(Gun).CannonReloadState != CR_ReadyToFire || !ROTankCannon(Gun).bClientCanFireCannon))
	{
       return;
	}

	Super(ROVehicleWeaponPawn).Fire(F);

	// Check for hint
	if (Gun != None && PlayerController(Controller) != None)
	    if (ROPlayer(Controller) != none)
            ROPlayer(Controller).CheckForHint(4);
}
////////////////////////////////////////////////////////////////////////
// ƒTƒuŽËŒ‚
// ‘oŠá‹¾ƒ|ƒWƒVƒ‡ƒ“‚Ì‚Æ‚«‚Ì”»’è’Ç‰Á
////////////////////////////////////////////////////////////////////////
function AltFire(optional float F)
{
//	if( DriverPositionIndex >= BinocPositionIndex && ROPlayer(Controller) != none &&
//		ROPlayerReplicationInfo(Controller.PlayerReplicationInfo).RoleInfo.bCanBeTankCommander)
//	{
//		ROPlayer(Controller).ServerSaveRallyPoint();
//		return;
//	}
//	else if( DriverPositionIndex >= BinocPositionIndex)
//		return;

	Super(ROVehicleWeaponPawn).AltFire(F);
}


////////////////////////////////////////////////////////////////////////
// AB2‚Ì”qŽØ
// modification allowing dual-magnification optics is here ( look for "GunsightZoomLevels" )
////////////////////////////////////////////////////////////////////////
simulated function SpecialCalcFirstPersonView(PlayerController PC, out actor ViewActor, out vector CameraLocation, out rotator CameraRotation )
{
    local vector x, y, z;
        local vector VehicleZ, CamViewOffsetWorld;
        local float CamViewOffsetZAmount;
        local coords CamBoneCoords;
        local rotator WeaponAimRot;
        local quat AQuat, BQuat, CQuat;

    GetAxes(CameraRotation, x, y, z);
        ViewActor = self;

    WeaponAimRot = rotator(vector(Gun.CurrentAim) >> Gun.Rotation);
    WeaponAimRot.Roll =  GetVehicleBase().Rotation.Roll;

        if( ROPlayer(Controller) != none )
        {
                 ROPlayer(Controller).WeaponBufferRotation.Yaw = WeaponAimRot.Yaw;
                 ROPlayer(Controller).WeaponBufferRotation.Pitch = WeaponAimRot.Pitch;
        }

        // This makes the camera stick to the cannon, but you have no control
        if (DriverPositionIndex < GunsightZoomLevels)
        {
                CameraRotation =  WeaponAimRot;
                // Make the cannon view have no roll
                CameraRotation.Roll = 0; // after all it should have a roll too, but let it be for now (Ami)
        	
		// test of modification for all guns - moved here from AB_AssaultGunCannonPawn
		// this in a turn makes T-34/76 and KV-1 sights working 
		// (applying the AddedPitch here to optic axis, instead of the projectile path)
		// and by the way makes the GunsightSettingMode corrections working in more interesting way :)
		CameraRotation.Pitch -= ROTankCannon(Gun).AddedPitch; // works good
	
	}
        else        if (bPCRelativeFPRotation)
        {
        //__________________________________________
        // First, Rotate the headbob by the player
        // controllers rotation (looking around) ---
        AQuat = QuatFromRotator(PC.Rotation);
        BQuat = QuatFromRotator(HeadRotationOffset - ShiftHalf);
        CQuat = QuatProduct(AQuat,BQuat);
        //__________________________________________
        // Then, rotate that by the vehicles rotation
        // to get the final rotation ---------------
        AQuat = QuatFromRotator(GetVehicleBase().Rotation);
        BQuat = QuatProduct(CQuat,AQuat);
        //__________________________________________
        // Make it back into a rotator!
        CameraRotation = QuatToRotator(BQuat);
        }
        else
                CameraRotation = PC.Rotation;

        if( IsInState('ViewTransition') && bLockCameraDuringTransition )
        {
                CameraRotation = Gun.GetBoneRotation( 'Camera_com' );
        }

           CamViewOffsetWorld = FPCamViewOffset >> CameraRotation;
        if(CameraBone != '' && Gun != None)
        {
                CamBoneCoords = Gun.GetBoneCoords(CameraBone);

                if( DriverPositions[DriverPositionIndex].bDrawOverlays && DriverPositionIndex < GunsightZoomLevels && !IsInState('ViewTransition'))
                {
                        CameraLocation = CamBoneCoords.Origin + (FPCamPos >> WeaponAimRot) + CamViewOffsetWorld;
                }
                else
                {
                        CameraLocation = Gun.GetBoneCoords('Camera_com').Origin;
                }

                if(bFPNoZFromCameraPitch)
                {
                        VehicleZ = vect(0,0,1) >> WeaponAimRot;

                        CamViewOffsetZAmount = CamViewOffsetWorld dot VehicleZ;
                        CameraLocation -= CamViewOffsetZAmount * VehicleZ;
                }
        }
        else
        {
                CameraLocation = GetCameraLocationStart() + (FPCamPos >> Rotation) + CamViewOffsetWorld;

                if(bFPNoZFromCameraPitch)
                {
                        VehicleZ = vect(0,0,1) >> Rotation;
                        CamViewOffsetZAmount = CamViewOffsetWorld Dot VehicleZ;
                        CameraLocation -= CamViewOffsetZAmount * VehicleZ;
                }
        }

    CameraRotation = Normalize(CameraRotation + PC.ShakeRot);
    CameraLocation = CameraLocation + PC.ShakeOffset.X * x + PC.ShakeOffset.Y * y + PC.ShakeOffset.Z * z;
}

////////////////////////////////////////////////////////////////////////
// AB2‚Ì”qŽØ
////////////////////////////////////////////////////////////////////////
simulated function DrawBinocsOverlay(Canvas Canvas) // works great, only recalculate it draw part of texture from 0, instead of setting negative sety
{
    local float ScreenRatio;

    // Calculate reticle drawing position (and position to draw black bars at)
    //posx = float(Canvas.SizeX - Canvas.SizeY) / 2.0 - float(Canvas.SizeY) * BinocsEnlargementFactor;

    ScreenRatio = float(Canvas.SizeY) / float(Canvas.SizeX);

        // Draw the reticle
	//Canvas.SetPos(posx, -BinocsEnlargementFactor * Canvas.SizeY);
  	//Canvas.DrawTile(BinocsOverlay, Canvas.SizeY * (1 + 2 * BinocsEnlargementFactor), Canvas.SizeY * (1 + 2 * BinocsEnlargementFactor), 0.0, 0.0, BinocsOverlay.USize, BinocsOverlay.VSize );

	Canvas.SetPos(0,0);
	Canvas.DrawTile(BinocsOverlay, Canvas.SizeX, Canvas.SizeY, 0.0 , (1 - ScreenRatio) * float(BinocsOverlay.VSize) / 2, BinocsOverlay.USize, float(BinocsOverlay.VSize) * ScreenRatio );
}



////////////////////////////////////////////////////////////////////////
// ƒfƒoƒbƒO—p
////////////////////////////////////////////////////////////////////////
simulated exec function SightSetMode()
{
	RMFTankCannon(Gun).SightSetMode();
}
simulated exec function OutSightData()
{
	RMFTankCannon(Gun).OutSightData();
}
simulated exec function FillAmmo()
{
	RMFTankCannon(Gun).FillAmmo();
}


////////////////////////////////////////////////////////////////////////
//@ƒfƒoƒbƒO•\Ž¦
////////////////////////////////////////////////////////////////////////
exec function DrawHitPoint()
{
	RMFTreadCraft(VehicleBase).DrawHitPoint();
}



////////////////////////////////////////////////////////////////////////
// ƒfƒtƒHƒ‹ƒgƒvƒƒpƒeƒB
////////////////////////////////////////////////////////////////////////

defaultproperties
{
     GunsightZoomLevels=1
     MaxRotateThreshold=2.000000
}
