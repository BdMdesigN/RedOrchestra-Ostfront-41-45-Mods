//=============================================================================
// ROHud
//=============================================================================
// New HUD for Red Orchestra
//=============================================================================
// Red Orchestra Source
// Copyright (C) 2003-2004 Erik Christensen
//=============================================================================

class RMFHud extends ROHud;

#exec OBJ LOAD FILE=..\textures\InterfaceArt2_tex.utx
#exec OBJ LOAD FILE=..\textures\RMFTextures.utx


var(ROHud) SpriteWidget	VehicleFuseTypeIcon;		// MŠÇ•\Ž¦

//=============================================================================
// Execs
//=============================================================================
function DrawVehicleIcon(Canvas Canvas, ROVehicle vehicle, optional ROVehicleWeaponPawn passenger)
{
    local AbsoluteCoordsInfo coords, coords2;
    local rotator myRot;
    local ROTreadCraft threadCraft;
    local SpriteWidget widget;
    local color vehicleColor;
    local float f;
    local int i, current, pending;
    local ROVehicleWeaponPawn wpawn;
    local float XL, YL, Y_one;
    local array<string> lines;
    local PlayerReplicationInfo PRI;
    local RMFTankCannon cannon;
    local ROVehicleWeapon weapon;
    local float myScale;
    local float modifiedVehicleOccupantsTextYOffset; // Used to offset text vertically when drawing coaxial ammo info
    local ROWheeledVehicle wheeled_vehicle;

    if (bHideHud)
        return;

    // Debug: draw tank name
    //canvas.setpos(0, canvas.clipY * 0.75);
    //canvas.DrawText(vehicle.class);

    //////////////////////////////////////
    // Draw vehicle icon
    //////////////////////////////////////

    // Figure what the scale is
    myScale = HudScale; // * ResScaleY;

    // Figure where to draw
    coords.PosX = Canvas.ClipX * VehicleIconCoords.X;
    coords.height = Canvas.ClipY * VehicleIconCoords.YL * myScale;
    coords.PosY = Canvas.ClipY * VehicleIconCoords.Y - coords.height;
    coords.width = coords.height;

    // Compute whole-screen coords
    coords2.PosX = 0; coords2.PosY = 0;
    coords2.width = Canvas.ClipX; coords2.height = canvas.ClipY;

    // Set initial passenger PosX (shifted if we're drawing ammo info,
    // else it's draw closer to the tank icon)
    VehicleOccupantsText.PosX = default.VehicleOccupantsText.PosX;

    // The IS2 is so frelling huge that it needs to use larger textures
    if (vehicle.bVehicleHudUsesLargeTexture)
        widget = VehicleIconAlt;
    else
        widget = VehicleIcon;

    // Figure what color to draw in
    f = vehicle.Health / vehicle.HealthMax;
    if (f > 0.75)
        vehicleColor = VehicleNormalColor;
    else if (f > 0.35)
        vehicleColor = VehicleDamagedColor;
    else
        vehicleColor = VehicleCriticalColor;
    widget.Tints[0] = vehicleColor;
    widget.Tints[1] = vehicleColor;

    // Draw vehicle icon
    widget.WidgetTexture = vehicle.VehicleHudImage;
    DrawSpriteWidgetClipped(Canvas, widget, coords, true);

    // Draw engine (if needed)
    f = vehicle.EngineHealth / vehicle.Default.EngineHealth;
    if (f < 0.95)
    {
        if (f < 0.35)
            VehicleEngine.WidgetTexture = VehicleEngineCriticalTexture;
        else
            VehicleEngine.WidgetTexture = VehicleEngineDamagedTexture;

        VehicleEngine.PosX = vehicle.VehicleHudEngineX;
        VehicleEngine.PosY = vehicle.VehicleHudEngineY;
        DrawSpriteWidgetClipped(Canvas, VehicleEngine, coords, true);
    }

    // Draw treaded vehicle specific stuff
    threadCraft = ROTreadCraft(vehicle);
    if (threadCraft != none)
    {
        // Update turret references
        if (threadCraft.CannonTurret == none)
            threadCraft.UpdateTurretReferences();

        // Draw threads (if needed)
        if (threadCraft.bLeftTrackDamaged)
        {
            VehicleThreads[0].TextureScale = threadCraft.VehicleHudThreadsScale;
            VehicleThreads[0].PosX = threadCraft.VehicleHudThreadsPosX[0];
            VehicleThreads[0].PosY = threadCraft.VehicleHudThreadsPosY;
            DrawSpriteWidgetClipped(Canvas, VehicleThreads[0], coords, true, XL, YL, false, true);
        }
        if (threadCraft.bRightTrackDamaged)
        {
            VehicleThreads[1].TextureScale = threadCraft.VehicleHudThreadsScale;
            VehicleThreads[1].PosX = threadCraft.VehicleHudThreadsPosX[1];
            VehicleThreads[1].PosY = threadCraft.VehicleHudThreadsPosY;
            DrawSpriteWidgetClipped(Canvas, VehicleThreads[1], coords, true, XL, YL, false, true);
        }

        // Update & draw look turret (if needed)
        if (passenger != none && passenger.IsA('RMFTankCannonPawn'))
        {
            threadCraft.VehicleHudTurretLook.Rotation.Yaw =
                vehicle.Rotation.Yaw - passenger.CustomAim.Yaw;
            widget.WidgetTexture = threadCraft.VehicleHudTurretLook;
            widget.Tints[0].A /= 2;
            widget.Tints[1].A /= 2;
            DrawSpriteWidgetClipped(Canvas, widget, coords, true);
            widget.Tints[0] = vehicleColor;
            widget.Tints[1] = vehicleColor;

            // Draw ammo count since we're a gunner
            if (bShowWeaponInfo)
            {
                // Shift passengers list farther to the right
                VehicleOccupantsText.PosX = VehicleOccupantsTextOffset;

                // Draw icon
                VehicleAmmoIcon.WidgetTexture = passenger.AmmoShellTexture;
                DrawSpriteWidget(Canvas, VehicleAmmoIcon);

                // Draw reload state icon (if needed)
                VehicleAmmoReloadIcon.WidgetTexture = passenger.AmmoShellReloadTexture;
                VehicleAmmoReloadIcon.Scale = passenger.getAmmoReloadState();
                DrawSpriteWidget(Canvas, VehicleAmmoReloadIcon);

                // Draw ammo count

                if( Passenger != none && passenger.Gun != none )
                {
                	VehicleAmmoAmount.Value = passenger.Gun.PrimaryAmmoCount();//999;
                }
                DrawNumericWidget(Canvas, VehicleAmmoAmount, Digits);

                // Draw ammo type
                cannon = RMFTankCannon(passenger.Gun);
                if (cannon != none && cannon.bMultipleRoundTypes)
                {
                    // Get ammo types
                    current = cannon.GetRoundsDescription(lines);
                    pending = cannon.GetPendingRoundIndex();

                    VehicleAmmoTypeText.OffsetY = default.VehicleAmmoTypeText.OffsetY * myScale;
                    if (myScale < 0.85)
                        Canvas.Font = GetConsoleFont(Canvas);
                    else
                        Canvas.Font = GetSmallMenuFont(Canvas);

                    i = (current + 1) % lines.length;
                    while (true)
                    {
                        if (i == pending)
                        	VehicleAmmoTypeText.text = lines[i]$"<-";
                        else
                        	VehicleAmmoTypeText.text = lines[i];

                        if (i == current)
                            VehicleAmmoTypeText.Tints[TeamIndex].A = 255;
                        else
                            VehicleAmmoTypeText.Tints[TeamIndex].A = 128;



                        DrawTextWidgetClipped(Canvas, VehicleAmmoTypeText, coords2, XL, YL, Y_one);
                        VehicleAmmoTypeText.OffsetY -= YL;

                        i = (i + 1) % lines.length;
                        if (i == (current + 1) % lines.length)
                            break;
                    }
                }
				//============================
				// MŠÇ•\Ž¦
				//============================
                if (cannon != none)
                {
					//============================
					// Œ»Ý‘•“U’†‚Ì’e‚ª’x‰„MŠÇ‚È‚çƒAƒCƒRƒ“•\Ž¦
					//============================
                	if( cannon.CurrentFuseType &&  cannon.HasDelayFuse() )
                	{
						DrawSpriteWidget(Canvas, VehicleFuseTypeIcon);
	               	}
                }
            	
                if (cannon != none)
                {
                    // Draw coaxial gun ammo info if needed
                    if (cannon.AltFireProjectileClass != none)
                    {
                        // Draw coaxial gun ammo icon
                        VehicleAltAmmoIcon.WidgetTexture = cannon.hudAltAmmoIcon;
                        DrawSpriteWidget(Canvas, VehicleAltAmmoIcon);

                        // Draw coaxial gun ammo ammount
                        VehicleAltAmmoAmount.Value = cannon.getNumMags();//999;
                        DrawNumericWidget(Canvas, VehicleAltAmmoAmount, Digits);

                        // Shift occupants list position to accomodate coaxial gun ammo info
                        modifiedVehicleOccupantsTextYOffset = VehicleAltAmmoOccupantsTextOffset * myScale;
                    }
                }
            }
        }

        // Update & draw turret
        if (threadCraft.CannonTurret != none)
        {
            myRot = rotator(vector(threadCraft.CannonTurret.CurrentAim) >> threadCraft.CannonTurret.Rotation);
            threadCraft.VehicleHudTurret.Rotation.Yaw = vehicle.Rotation.Yaw - myRot.Yaw;
            widget.WidgetTexture = threadCraft.VehicleHudTurret;
            DrawSpriteWidgetClipped(Canvas, widget, coords, true);
        }
    }

    // Draw MG ammo info (if needed)
    if (bShowWeaponInfo && passenger != none && passenger.bIsMountedTankMG)
    {
        weapon = ROVehicleWeapon(passenger.Gun);
        if (weapon != none)
        {
            // Offset vehicle passenger names
            VehicleOccupantsText.PosX = VehicleOccupantsTextOffset;

            // Draw ammo icon
            VehicleMGAmmoIcon.WidgetTexture = weapon.hudAltAmmoIcon;
            DrawSpriteWidget(Canvas, VehicleMGAmmoIcon);

            // Draw ammo count
            VehicleMGAmmoAmount.Value = weapon.getNumMags();
            DrawNumericWidget(Canvas, VehicleMGAmmoAmount, Digits);
        }
    }

    // Draw rpm/speed/throttle gauges if we're the driver
    if (passenger == none)
    {
        wheeled_vehicle = ROWheeledVehicle(vehicle);
        if (wheeled_vehicle != none)
        {
            // Get team index
            if (vehicle.Controller != none && vehicle.Controller.PlayerReplicationInfo != none &&
                vehicle.Controller.PlayerReplicationInfo.Team != none)
            {
                if (vehicle.Controller.PlayerReplicationInfo.Team.TeamIndex == AXIS_TEAM_INDEX)
                    i = AXIS_TEAM_INDEX;
                else
                    i = ALLIES_TEAM_INDEX;
            }
            else
                i = AXIS_TEAM_INDEX;

            // Update textures for backgrounds
            VehicleSpeedIndicator.WidgetTexture = VehicleSpeedTextures[i];
            VehicleRPMIndicator.WidgetTexture = VehicleRPMTextures[i];

            // Draw backgrounds
            DrawSpriteWidgetClipped(Canvas, VehicleSpeedIndicator, coords, true, XL, YL, false, true);
            DrawSpriteWidgetClipped(Canvas, VehicleRPMIndicator, coords, true, XL, YL, false, true);

            // Get speed value & update rotator
            f = (((VSize(wheeled_vehicle.Velocity) * 3600)/60.35)/1000);
            //f = 100;
            f *= VehicleSpeedScale[i];
            f += VehicleSpeedZeroPosition[i];

            // Check if we should reset needles rotation
            if (VehicleNeedlesLastRenderTime < Level.TimeSeconds - 0.5)
               f = VehicleLastSpeedRotation;

            // Calculate modified rotation (to limit rotation speed)
            if (f < VehicleLastSpeedRotation)
                VehicleLastSpeedRotation = max(f, VehicleLastSpeedRotation -
                    (Level.TimeSeconds - VehicleNeedlesLastRenderTime) * VehicleNeedlesRotationSpeed);
            else
                VehicleLastSpeedRotation = min(f, VehicleLastSpeedRotation +
                    (Level.TimeSeconds - VehicleNeedlesLastRenderTime) * VehicleNeedlesRotationSpeed);
            TexRotator(VehicleSpeedNeedlesTextures[i]).Rotation.Yaw = VehicleLastSpeedRotation;

            // Get RPM value & update rotator
            f = wheeled_vehicle.EngineRPM / 100;
            //f = 35;
            f *= VehicleRPMScale[i];
            f += VehicleRPMZeroPosition[i];

            // Check if we should reset needles rotation
            if (VehicleNeedlesLastRenderTime < Level.TimeSeconds - 0.5)
               f = VehicleLastSpeedRotation;

            // Calculate modified rotation (to limit rotation speed)
            if (f < VehicleLastRPMRotation)
                VehicleLastRPMRotation = max(f, VehicleLastRPMRotation -
                    (Level.TimeSeconds - VehicleNeedlesLastRenderTime) * VehicleNeedlesRotationSpeed);
            else
                VehicleLastRPMRotation = min(f, VehicleLastRPMRotation +
                    (Level.TimeSeconds - VehicleNeedlesLastRenderTime) * VehicleNeedlesRotationSpeed);
            TexRotator(VehicleRPMNeedlesTextures[i]).Rotation.Yaw = VehicleLastRPMRotation;

            // Save last updated time
            VehicleNeedlesLastRenderTime = Level.TimeSeconds;

            // Update textures for needles
            VehicleSpeedIndicator.WidgetTexture = VehicleSpeedNeedlesTextures[i];
            VehicleRPMIndicator.WidgetTexture = VehicleRPMNeedlesTextures[i];

            // Draw needles
            DrawSpriteWidgetClipped(Canvas, VehicleSpeedIndicator, coords, true, XL, YL, false, true);
            DrawSpriteWidgetClipped(Canvas, VehicleRPMIndicator, coords, true, XL, YL, false, true);

            // Check if we should draw throttle
            if (ROPlayer(vehicle.Controller) != none
                && ( (ROPlayer(vehicle.Controller).bInterpolatedTankThrottle && threadCraft != none) ||
                     (ROPlayer(vehicle.Controller).bInterpolatedVehicleThrottle && threadCraft == none) ))
            {
                // Draw throttle background
                DrawSpriteWidgetClipped(Canvas, VehicleThrottleIndicatorBackground, coords, true, XL, YL, false, true);

                // Save YL for use later
                Y_one = YL;

                // Check which throttle variable we should use
                if (PlayerOwner != vehicle.Controller)
                {
                    // Is spectator
                    if (wheeled_vehicle.ThrottleRep <= 100)
                        f = (wheeled_vehicle.ThrottleRep * -1.0) / 100.0;
                    else
                        f = float(wheeled_vehicle.ThrottleRep - 101) / 100.0;
                }
                else
                    f = wheeled_vehicle.Throttle;

                // Figure which part to draw (top or bottom) depending if throttle is positive or negative,
                // updated the scale value and draw the widget
                if (f ~= 0)
                {
                }
                else if (f > 0)
                {
                    VehicleThrottleIndicatorTop.Scale = VehicleThrottleTopZeroPosition
                        + f * (VehicleThrottleTopMaxPosition - VehicleThrottleTopZeroPosition);
                    DrawSpriteWidgetClipped(Canvas, VehicleThrottleIndicatorTop, coords, true, XL, YL, false, true);
                }
                else
                {
                    VehicleThrottleIndicatorBottom.Scale = VehicleThrottleBottomZeroPosition
                        - f * (VehicleThrottleBottomMaxPosition - VehicleThrottleBottomZeroPosition);
                    DrawSpriteWidgetClipped(Canvas, VehicleThrottleIndicatorBottom, coords, true, XL, YL, false, true);
                }

                // Draw throttle foreground
                DrawSpriteWidgetClipped(Canvas, VehicleThrottleIndicatorForeground, coords, true, XL, YL, false, true);

                // Draw the lever thingy
                if (f ~= 0)
                {
                    VehicleThrottleIndicatorLever.OffsetY =
                        default.VehicleThrottleIndicatorLever.OffsetY -
                        Y_one * VehicleThrottleTopZeroPosition;
                }
                else if (f > 0)
                {
                    VehicleThrottleIndicatorLever.OffsetY =
                        default.VehicleThrottleIndicatorLever.OffsetY -
                        Y_one * VehicleThrottleIndicatorTop.scale;
                }
                else
                {
                    VehicleThrottleIndicatorLever.OffsetY =
                        default.VehicleThrottleIndicatorLever.OffsetY -
                        Y_one * (1 - VehicleThrottleIndicatorBottom.Scale);
                }
                DrawSpriteWidgetClipped(Canvas, VehicleThrottleIndicatorLever, coords, true, XL, YL, true, true);

                // Shift passengers list farther to the right
                VehicleOccupantsText.PosX = VehicleGaugesOccupantsTextOffset;
            }
            else
            {
                // Shift passengers list farther to the right
                VehicleOccupantsText.PosX = VehicleGaugesNoThrottleOccupantsTextOffset;
            }

            // hax to get proper x offset on non-4:3 screens
            VehicleOccupantsText.PosX *= Canvas.ClipY / Canvas.ClipX * 4 / 3;
        }
    }

    // Draw occupant dots
    for (i = 0; i < vehicle.VehicleHudOccupantsX.Length; i++)
    {
        if (vehicle.VehicleHudOccupantsX[i] ~= 0)
            continue;

        if (i == 0)
        {
            // Draw driver
            if (passenger == none) // we're the driver
                VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsPlayerColor;
            else if (vehicle.Driver != none)
                VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsOccupiedColor;
            else
                VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsVacantColor;

            VehicleOccupants.PosX = vehicle.VehicleHudOccupantsX[0];
            VehicleOccupants.PosY = vehicle.VehicleHudOccupantsY[0];
            DrawSpriteWidgetClipped(Canvas, VehicleOccupants, coords, true);
        }
        else
        {
            if (i - 1 >= vehicle.WeaponPawns.Length)
            {
               // warn("VehicleHudOccupantsX[" $ i $ "] causes out-of-bounds access in vehicle.WeaponPawns[] (lenght is " $ vehicle.WeaponPawns.Length $ ")");
                continue;
            }
            else if (vehicle.WeaponPawns[i-1] == passenger && passenger != none)
                VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsPlayerColor;
            else if (vehicle.WeaponPawns[i-1].PlayerReplicationInfo != none)
            {
                if (passenger != none &&
                    passenger.PlayerReplicationInfo != none &&
                    vehicle.WeaponPawns[i-1].PlayerReplicationInfo == passenger.PlayerReplicationInfo)
                {
                    VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsPlayerColor;
                }
                else
                    VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsOccupiedColor;
            }
            else
                VehicleOccupants.Tints[TeamIndex] = VehiclePositionIsVacantColor;

            // Check to make sure replicated array index doesn'T cause out of bounds access
            current = vehicle.WeaponPawns[i-1].PositionInArray;
            if (current >= vehicle.VehicleHudOccupantsX.Length - 1 ||
                current < 0)
            {
                warn("vehicle.WeaponPawns[" $ (i-1) $ "].PositionInArray "$current$" causes out-of-bounds access in vehicle.VehicleHudOccupantsX[] (lenght is " $ vehicle.VehicleHudOccupantsX.Length $ ")");
            }
            else
            {
                VehicleOccupants.PosX = vehicle.VehicleHudOccupantsX[current + 1];
                VehicleOccupants.PosY = vehicle.VehicleHudOccupantsY[current + 1];
                DrawSpriteWidgetClipped(Canvas, VehicleOccupants, coords, true);
            }
        }
    }


    //////////////////////////////////////
    // Draw passenger names
    //////////////////////////////////////

    // Get self's PRI
    if (passenger != none)
        PRI = passenger.PlayerReplicationInfo;
    else
        PRI = vehicle.PlayerReplicationInfo;

    // Clear lines array
    lines.length = 0;

    // Shift text up some more if we're the driver and we're displaying capture bar
    if (bDrawingCaptureBar && vehicle.PlayerReplicationInfo == PRI)
       modifiedVehicleOccupantsTextYOffset -= 0.12 * Canvas.SizeY * myScale;

    // Driver's name
    if (vehicle.PlayerReplicationInfo != none)
        if (vehicle.PlayerReplicationInfo != PRI) // don't draw our own name!
            lines[lines.length] = class'ROVehicleWeaponPawn'.default.DriverHudName $ ": " $
                vehicle.PlayerReplicationInfo.PlayerName;

    // Passengers' names
    for (i = 0; i < vehicle.WeaponPawns.Length; i++)
    {
        wpawn = ROVehicleWeaponPawn(vehicle.WeaponPawns[i]);
        if (wpawn != none && wpawn.PlayerReplicationInfo != none)
            if (wpawn.PlayerReplicationInfo != PRI) // don't draw our own name!
                lines[lines.length] = wpawn.HudName $ ": " $
                    wpawn.PlayerReplicationInfo.PlayerName;
    }

    // Draw the lines
    if (lines.Length > 0)
    {
    	if (passenger != none && passenger.IsA('RMFTankCannonPawn'))
    	{
	        VehicleOccupantsText.OffsetY = -40 * myScale;
    	}
		else
    	{
	        VehicleOccupantsText.OffsetY = default.VehicleOccupantsText.OffsetY * myScale;
    	}
        VehicleOccupantsText.OffsetY += modifiedVehicleOccupantsTextYOffset;
        Canvas.Font = GetSmallMenuFont(Canvas);

        for (i = lines.Length - 1; i >= 0 ; i--)
        {
            VehicleOccupantsText.text = lines[i];
            DrawTextWidgetClipped(Canvas, VehicleOccupantsText, coords2, XL, YL, Y_one);
            VehicleOccupantsText.OffsetY -= YL;
        }
    }

}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     VehicleFuseTypeIcon=(WidgetTexture=Texture'RMFTextures.HUD.fusetype_delay',RenderStyle=STY_Alpha,TextureCoords=(X2=32,Y2=32),TextureScale=0.300000,DrawPivot=DP_LowerLeft,PosX=0.150000,PosY=0.990000,OffsetY=-8,ScaleMode=SM_Left,Scale=1.000000,Tints[0]=(B=255,G=255,R=255,A=255),Tints[1]=(B=255,G=255,R=255,A=255))
     VehicleOccupantsText=(OffsetX=0)
     VehicleAltAmmoIcon=(PosX=0.270000)
     VehicleAltAmmoAmount=(PosX=0.270000)
}
