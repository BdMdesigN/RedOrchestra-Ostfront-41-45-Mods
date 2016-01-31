//=============================================================================
// ROBullet
//=============================================================================
// ŠÑ’Ê‚ð’Ç‰Á
//=============================================================================
class RMFBullet extends ROBullet
	abstract;
	

Enum E_AmmoType							
{
	AMMO_FMJ,	// Full Metal Jacket
	AMMO_AP,	// Armor Piercing 
	AMMO_APHE,	// Armor Piercing High Explosive
	AMMO_APC,	// Armor Piercing Capped 
	AMMO_APBC,	// Armor Piercing Ballistic Capped
	AMMO_APCBC,	// Armor Piercing Capped Ballistic Capped
	AMMO_APCR,	// Armor Piercing Composite Rigid
	AMMO_HE,	// High Explosive
	AMMO_HEAT	// High Explosive Anti Tank
};

var	E_AmmoType	AmmotType;	// ’e–òƒ^ƒCƒv

var		float 	PenetrationMag;						// ŠÑ’Ê—Í”{—¦
var		float 	MagnificationTable[20];				// ÞŽ¿‚É‚æ‚éŠÑ’Ê”{—¦
var		float 	DecrementTable[20];					// ÞŽ¿‚É‚æ‚éŒ¸Š—¦
var		float 	AngleTable[11];						// Šp“x‚É‚æ‚éŒ¸Š—¦
var 	int		PenetrationTable[29];				// ŠÑ’Ê—Íƒe[ƒuƒ‹
var		float 	DeflectMinimumAngle[9];				// ’e–òƒ^ƒCƒv‚É‚æ‚é”½ŽË‰Â”\‚ÈÅ¬Šp“x
var		float 	DeflectDecrement[9];				// ’e–òƒ^ƒCƒv‚É‚æ‚é”½ŽËŒã‚ÌŠÑ’Ê—Í’á‰º”{—¦


var()   class<Emitter>  ShellDeflectEffectClass; 	// ’›’eƒGƒtƒFƒNƒg
var() 		float 		DampenFactor;
var() 		float 		DampenFactorParallel;
var 		Pawn 		SavedHitActor;
var 		vector 		SavedHitLocation;
var 		vector 		SavedHitNormal;

var()	class<actor>		DeflectEffect;

var		vector			LaunchLocation;				// ”­ŽËƒ|ƒCƒ“ƒg
var		vector			LastHit;					// ÅIƒqƒbƒgêŠ

var		sound			VehicleDeflectSound;		// ’e‚©‚ê‚½‰¹
var		sound			VehicleHitSound;			// “–‚½‚Á‚½‰¹
var()   class<Emitter>  ShellHitVehicleEffectClass;	// ƒqƒbƒgƒGƒtƒFƒNƒgƒNƒ‰ƒX
// Effects
var()   class<Emitter>  ExplosionDirtEffectClass;    // Effect for this shell hitting dirt
var()   class<Emitter>  ExplosionSnowEffectClass;    // Effect for this shell hitting snow
var()   class<Emitter>  ExplosionWoodEffectClass;    // Effect for this shell hitting wood
var()   class<Emitter>  ExplosionRockEffectClass;    // Effect for this shell hitting rock
var()   class<Emitter>  ExplosionWaterEffectClass;   // Effect for this shell hitting water

var byte HitCount;		// How many times we have hit something

//var() string MatName[20];							// Œ¸Š—¦

// ƒfƒoƒbƒO—p
var bool Firsthit;									// ‰‰ñƒqƒbƒg
var bool Drawdebuglines;
var	bool bDidExplosionFX; 							// Šù‚É”š”­ƒGƒtƒFƒNƒg‚µ‚½
var bool DisplayHitDist;							// ƒqƒbƒg‹——£

var	bool	bCannonShell;							// ‘åŒûŒa–C’e

var	bool	bFuseFire;								// ’x‰„MŠÇ”­“®Ï‚Ý
var	bool	bDelayFuse;								// ’x‰„MŠÇ‚ðŽg—p‚·‚é‚©
var	bool	bExplosiveAmmo;							// ”š”­‚·‚é‚©
var float	FuseTime;								// ’x‰„MŠÇ‚ÌŽžŠÔ
var	vector	LastHitNormal;							// ÅIƒqƒbƒg–@ü
var	bool	bPenetrateExplode;						// ŠÑ’Ê”š”j
var Actor	PenetrateActor;							// ŠÑ’Ê”š”jæActor


var		sound		ExplosionSound[4];          	// ”š”­ƒTƒEƒ“ƒh

//var	xEmitter	Trail;
var 	class<Emitter>      mTracerClass;
var() 	Emitter 			mTracer;
var() 	float				mTracerInterval;
var() 	float				mTracerPullback;
var() 	Effects 			Corona;
var		bool				bTracer;	// ‰gŒõ’e		
var		StaticMesh			DeflectedMesh;
		
struct RangePoint
{
	var() int           	Range;     			// Meter distance for this range setting
	var() float           	RangeValue;     	// The adjustment value for this range setting
};

var() 	array<RangePoint>	MechanicalRanges; 	// The range setting values for tank cannons that do mechanical pitch adjustments for aiming
var() 	array<RangePoint>	OpticalRanges;    	// The range setting values for tank cannons that do optical sight adjustments for aiming
var		bool				bMechanicalAiming;  // Uses the Mechanical Range settings for this projectile
var		bool				bOpticalAiming;  	// Uses the Optical Range settings for this projectile
var bool bHitWater;

var   class<DamageType>	   MyExplosionDamageType;


////////////////////////////////////////////////////////////////////////
// replication
////////////////////////////////////////////////////////////////////////
replication
{
	//ƒT[ƒo‚©‚çƒNƒ‰ƒCƒAƒ“ƒg‚Ö•¡»‚·‚é•Ï”
	reliable if( Role==ROLE_Authority )
		bCannonShell, bFuseFire, bDelayFuse, bExplosiveAmmo, FuseTime, LastHitNormal, bPenetrateExplode, PenetrateActor, PenetrationMag, Firsthit, bTracer;
}

//=============================================================================
// PostBeginPlay
//=============================================================================
simulated function PostBeginPlay()
{

    // Set a longer lifespan for the shell if there is a possibility of a very long range shot
	Switch(Level.ViewDistanceLevel)
	{
		case VDL_Default_1000m:
			break;
		case VDL_Medium_2000m:
            Lifespan *= 1.3;
			break;
		case VDL_High_3000m:
            Lifespan *= 1.8;
			break;
		case VDL_Extreme_4000m:
            Lifespan *= 2.8;
			break;
	}
	if (Level.NetMode != NM_DedicatedServer && bTracer)
	{
		mTracer = Spawn(mTracerClass,self,,(Location+(Normal(Velocity))*mTracerPullback));
	}

	if ( Level.NetMode != NM_DedicatedServer && bCorona)
	{
		Corona = Spawn(class'RocketCorona',self);
	}

	if (PhysicsVolume.bWaterVolume)
	{
		bHitWater = True;
		Velocity=0.6*Velocity;
	}
    if ( Level.bDropDetail )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}

	Velocity = Vector(Rotation) * Speed;
	BCInverse = 1 / BallisticCoefficient;


	if (Role == ROLE_Authority && Instigator != None )
	{
		if(Instigator.HeadVolume.bWaterVolume)
			Velocity *= 0.5;
	}

	super(Projectile).PostBeginPlay();


	// ŠJŽnˆÊ’u‚ð‹L˜^
    LaunchLocation = location;
    LastHit = vect(0, 0, 0);
	bFuseFire = false;
	bPenetrateExplode = false;
	PenetrateActor = none;
}

//=============================================================================
// Tick - Update physics
//=============================================================================
simulated function Tick(float DeltaTime)
{
	local rotator Rot;

	super(ROBallisticProjectile).Tick(DeltaTime);

	//------------------------
	// is•ûŒü‚ÉŒü‚¯‚é
	//------------------------
	Rot.pitch	= rotator( Velocity ).pitch;
	Rot.roll	= Rotation.roll;
	Rot.yaw		= rotator( Velocity ).yaw;
	SetRotation( Rot );

	if( HitCount == 0 && !bCollideActors && Level.NetMode == NM_Client)
	{
		SetCollision(True,True);
	}


}

//=============================================================================
// ’…’n
//=============================================================================
simulated function Landed(vector HitNormal)
{
	local float InAngle;
    local vector X,Y,Z;
    local float InAngleDegrees;

	//============================
	// “üŽËŠp‚ð‹‚ß‚é
	//============================
    GetAxes(rotator(HitNormal),X,Y,Z);
	InAngle= Acos(Normal(-Normal(Velocity)) dot Normal(X));
	InAngleDegrees = Abs(90-(InAngle * 57.2957795131));
	
	super.Landed( HitNormal );
	
	//============================
	// ”š”­‚·‚é’e‚©‚Ç‚¤‚©
	//============================
	if( bExplosiveAmmo )
	{
		//============================
		// ’x‰„MŠÇ?
		//============================
		if( bDelayFuse )
		{
			LastHitNormal = HitNormal;
			
			//============================
			// ’x‰„MŠÇì“®
			//============================
			SetTimer( FuseTime, false );
			bFuseFire = true;
		}
		//============================
		// ’…”­‚È‚ç‚·‚®”š”­
		//============================
		else
		{
			//============================
			// HEAT‚Ìê‡‚Í— ‘¤ƒ`ƒFƒbƒN
			//============================
			if( AmmotType == AMMO_HEAT )
			{
				//============================
				// ŠÑ’Ê—ÍŒ¸Š
				//============================
				Damage *= GetPenetrationProbability( InAngleDegrees );
				if(!PenetrateCheck( HitNormal, InAngleDegrees ))
				{
					Explode(Location, HitNormal);
				}
	 			return;
			}
			else
			{
				Explode(Location, HitNormal);
				return;
			}
		}
	}	
	
	// •¨——Ž‰º‚ªŽ~‚Ü‚Á‚½‚çŒ³‚Ì•¨—‚É–ß‚·
	if( Physics == PHYS_Falling )
	{
	    SetPhysics(PHYS_Projectile);
	    bTrueBallistics = true;
	}

	
}

//=============================================================================
// GetPenetrationNumber
//=============================================================================
simulated function int GetPenetrationNumber(vector Distance)
{
	local float MeterDistance;

	MeterDistance = VSize(Distance)/52.48;

	if( MeterDistance < 25)			return PenetrationTable[0];
	else if ( MeterDistance < 50)	return PenetrationTable[1];
	else if ( MeterDistance < 100)	return PenetrationTable[2];
	else if ( MeterDistance < 200)	return PenetrationTable[3];
	else if ( MeterDistance < 300)	return PenetrationTable[4];
	else if ( MeterDistance < 400)	return PenetrationTable[5];
	else if ( MeterDistance < 500)	return PenetrationTable[6];
	else if ( MeterDistance < 600)	return PenetrationTable[7];
	else if ( MeterDistance < 700)	return PenetrationTable[8];
	else if ( MeterDistance < 800)	return PenetrationTable[9];
	else if ( MeterDistance < 900)	return PenetrationTable[10];
	else if ( MeterDistance < 1000)	return PenetrationTable[11];
	else if ( MeterDistance < 1100)	return PenetrationTable[12];
	else if ( MeterDistance < 1200)	return PenetrationTable[13];
	else if ( MeterDistance < 1300)	return PenetrationTable[14];
	else if ( MeterDistance < 1400)	return PenetrationTable[15];
	else if ( MeterDistance < 1500)	return PenetrationTable[16];
	else if ( MeterDistance < 1600)	return PenetrationTable[17];
	else if ( MeterDistance < 1700)	return PenetrationTable[18];
	else if ( MeterDistance < 1800)	return PenetrationTable[19];
	else if ( MeterDistance < 1900)	return PenetrationTable[20];
	else if ( MeterDistance < 2000)	return PenetrationTable[21];
	else if ( MeterDistance < 2100)	return PenetrationTable[22];
	else if ( MeterDistance < 2200)	return PenetrationTable[23];
	else if ( MeterDistance < 2300)	return PenetrationTable[24];
	else if ( MeterDistance < 2400)	return PenetrationTable[25];
	else if ( MeterDistance < 2500)	return PenetrationTable[26];
	else if ( MeterDistance < 2600)	return PenetrationTable[27];
	else 							return PenetrationTable[28];
}

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
// GetDeflectMinimum
//=============================================================================
simulated function float GetDeflectMinimum( E_AmmoType Type )
{
	return DeflectMinimumAngle[Type];
}

	



//=============================================================================
// HitWall - The bullet hit a wall
//=============================================================================
simulated function HitWall(vector HitNormal, actor Wall)
{
	local float InAngle;
    local vector X,Y,Z;
    local float InAngleDegrees;
	local vector VNorm;
    local RODestroyableStaticMesh DestroMesh;
	local int i;

//	Level.Game.Broadcast(self, "HitWall Wall="$Wall);
	

	local float MeterDistance;
	local Vector V1, V2;

	V1 = Location;
	V2 = LaunchLocation;


	MeterDistance = VSize(V2 - V1)/52.48;

//	Spawn(class'DebugSphere',,,V2);
//	Spawn(class'DebugSphere',,,HitLoc);

	//============================
	// ƒfƒoƒbƒO•\Ž¦
	//============================
	if(DisplayHitDist && HitCount==0)
	{
		ROPlayer(Instigator.Controller).ClientMessage("HitDistance ="$MeterDistance$" meter");
	}	
	
	//============================
	// ’x‰„MŠÇ”­“®Ï‚Ý‚È‚ç”²‚¯‚é
	//============================
	if( bFuseFire )
	{
		return;
	}

	//============================
	// “üŽËŠp‚ð‹‚ß‚é
	//============================
    GetAxes(rotator(HitNormal),X,Y,Z);
	InAngle= Acos(Normal(-Normal(Velocity)) dot Normal(X));
	InAngleDegrees = Abs(90-(InAngle * 57.2957795131));
//	Level.Game.Broadcast(self, "InAngleDegrees="$InAngleDegrees);

	
	//============================
	// ƒfƒoƒbƒO—p
	//============================
	if( Drawdebuglines )
	{
		DrawStayingDebugLine( Location, Location-(Normal(Velocity)*20), 0, 255, 0);
		VNorm = (Normal(Velocity) dot HitNormal) * HitNormal;
		DrawStayingDebugLine( Location, Location-( (-Normal(Velocity) + 2.0f *  VNorm )*20), 0, 255, 0);
	}
	
	//------------------------
	// 
	//------------------------
	if ( WallHitActor != none && WallHitActor == Wall)
	{
		return;
	}
	
	//------------------------
	// ”j‰óƒ‚ƒfƒ‹‚Éˆê’U•ÏŠ·
	//------------------------
    DestroMesh = RODestroyableStaticMesh(Wall);
	
	//------------------------
	// ƒqƒbƒg”ƒAƒbƒv
	//------------------------
	HitCount++;
	
	//------------------------
	// ƒhƒ‰ƒCƒo[‚ÉÕŒ‚
	//------------------------
	if( Level.NetMode != NM_DedicatedServer )
	{
		if( Wall.IsA('ROVehicle') )
		{
			ShakeDriver( ROVehicle(Wall).Controller );
			
	        for( i = 0; i < ROVehicle(Wall).WeaponPawns.Length; i++)
	        {
	        	if( ROVehicle(Wall).WeaponPawns[i] != none )
	        	{
	        		//Level.Game.Broadcast(self, "Cont="$ROVehicle(Wall).WeaponPawns[i].Controller);
					ShakeDriver( ROVehicle(Wall).WeaponPawns[i].Controller );
				}
	        }
		}
	}
	
	//============================
	// ”š”­‚·‚é’e‚©‚Ç‚¤‚©
	//============================
	if( bExplosiveAmmo )
	{
		//============================
		// ’x‰„MŠÇ?
		//============================
		if( bDelayFuse )
		{
			LastHitNormal = HitNormal;
			
			//============================
			// ’x‰„MŠÇì“®
			//============================
			SetTimer( FuseTime, false );
			bFuseFire = true;
		}
		//============================
		// ’…”­‚È‚ç‚·‚®”š”­
		//============================
		else
		{
//			Level.Game.Broadcast(self, "Explode");
			if( AmmotType != AMMO_HEAT )
			{
				Explode(Location, HitNormal);
				return;
			}
		}
	}

	//============================
	// íŽÔ
	//============================
    if( Wall.IsA('RMFTreadCraft') )
	{
		//============================
		// ŽÔ‘ÌŠÑ’Êƒ`ƒFƒbƒN
		//============================
		if(!RMFTreadCraft(Wall).ShouldBodyPenetrate(Location, Normal(Velocity), GetPenetrationNumber(LaunchLocation-Location), self) )
	    {
			//============================
			// ’µ’eƒGƒtƒFƒNƒg
			//============================
			if ( ShellDeflectEffectClass != None && (Level.NetMode != NM_DedicatedServer))
			{
				PlaySound( VehicleDeflectSound, , 5.5 * TransientSoundVolume, , , 1.5 );
				Spawn( ShellDeflectEffectClass, , , Location + HitNormal*16, rotator( HitNormal ) );
			}
			
			//============================
			// ’µ’eƒ`ƒFƒbƒN
			//============================
			if( HitCount < 2 && (  DeflectCheck( HitNormal, InAngleDegrees ) || ( bCannonShell && !bExplosiveAmmo ) || ( bCannonShell && bExplosiveAmmo && bDelayFuse && !bFuseFire ) ))
			{
				//============================
				// ’µ’eŽÀs
				//============================
				Deflect( HitNormal );
			}	
			//============================
			// ’µ’e‚µ‚È‚©‚Á‚½‚çÁ‹Ži’x‰„MŠÇ‚Ìˆ—‚ð“ü‚ê‚é—\’èj
			//============================
			else
			{
				//============================
				// ’x‰„MŠÇH
				//============================
				if( bDelayFuse )
				{
					//============================
					// ’x‰„MŠÇ”­“®‚µ‚Ä‚½‚ç’e‚ð‚»‚Ìê‚ÅŽ~‚ß‚é
					//============================
					if( bFuseFire )
					{
						//============================
						// ‚»‚Ìê‚ÅŽ~‚ß‚é
						//============================
						Velocity = vect(0, 0, 0);
						Speed = VSize(Velocity);
						
						//============================
						// Ž©—R—Ž‰º
						//============================
					    SetPhysics(PHYS_Falling);
					    bTrueBallistics = false;
					    Acceleration = PhysicsVolume.Gravity;
						
						return;
					}
				}
				else
				{
					//============================
					// HEAT‚È‚ç”š”­
					//============================
					if( AmmotType == AMMO_HEAT )
					{
						//Level.Game.Broadcast(self, "InAngleDegrees"$InAngleDegrees);
						Explode(Location, HitNormal);
						return;
					}
					else
					{
//						if (Level.NetMode == NM_DedicatedServer)
//						{
//							bCollided = true;
//							SetCollision(False,False);
//						}
//						else
//						{
//							Destroy();
//						}
						bCollided = true;						
						SetCollision(False,False);						
						Destroy();
					}
				}
			}
			return;
		}
		//============================
		// ŠÑ’Ê‚µ‚½‚çŠÑ’ÊƒGƒtƒFƒNƒgÄ¶
		//============================
		else
		{
			//Level.Game.Broadcast(self, "RMFWheeledVehicle Penetrate");
			
			//============================
			// ŠÑ’Ê‚µ‚½‚çŠÑ’ÊƒGƒtƒFƒNƒgÄ¶
			//============================
		 	if ( Level.NetMode != NM_DedicatedServer)
			{
			    PlaySound(VehicleHitSound,,5.5*TransientSoundVolume,,,1.5);
			    if ( EffectIsRelevant(Location,false) )
			    {
					Spawn( ShellHitVehicleEffectClass, , , Location, rotator( HitNormal ) );
			    }
			}
			
			//============================
			// ŠÑ’Ê‚µ‚½‚çŽÔ—¼‚Éƒ_ƒ[ƒW
			//============================
			if (Role == ROLE_Authority)
			{
				
				//============================
				// HEAT‚ÍŠp“x‚Åƒ_ƒ[ƒWŒƒŒ¸
				//============================
				if( AmmotType == AMMO_HEAT )
				{
					Damage *= GetPenetrationProbability( InAngleDegrees );
				}

				//Level.Game.Broadcast(self, "InAngleDegrees"$InAngleDegrees);
				Wall.TakeDamage(Damage - 20 * (1 - VSize(Velocity) / default.Speed), instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
				MakeNoise(1.0);
			}

			//============================
			// ’x‰„MŠÇH
			//============================
			if( bDelayFuse )
			{
				//============================
				// ’x‰„MŠÇ”­“®‚µ‚Ä‚½‚ç’e‚ð‚»‚Ìê‚ÅŽ~‚ß‚é
				//============================
				if( bFuseFire )
				{
		    		bPenetrateExplode = true;
					PenetrateActor =  Wall;
					
					//============================
					// ‚»‚Ìê‚ÅŽ~‚ß‚é
					//============================
					SetLocation( Location + Normal(Velocity) * 80 );
					Velocity = vect(0, 0, 0);
					Speed = VSize(Velocity);
					
					//============================
					// Ž©—R—Ž‰º
					//============================
				    SetPhysics(PHYS_Falling);
				    bTrueBallistics = false;
				    Acceleration = PhysicsVolume.Gravity;
					
					return;
				}
			}
    		else
    		{
		    	//============================
				// ŠÑ’Ê‚µ‚½‚ç’e‚ðÁ‚·i’x‰„MŠÇ‚Ìˆ—‚ð“ü‚ê‚é—\’èj
				//============================
//				if (Level.NetMode == NM_DedicatedServer)
//				{
//					bCollided = true;
//					SetCollision(False,False);
//				}
//				else
//				{
//					Destroy();
//				}
				bCollided = true;
				SetCollision(False,False);
    			Destroy();
				return;
    		}
		}
	}

	//============================
	// ƒ^ƒCƒ„•t‚«ŽÔ—¼
	//============================
    if( Wall.IsA('RMFWheeledVehicle') )
	{
		//============================
		// ŽÔ‘ÌŠÑ’Êƒ`ƒFƒbƒN
		//============================
		if(!RMFWheeledVehicle(Wall).ShouldBodyPenetrate(Location, Normal(Velocity), GetPenetrationNumber(LaunchLocation-Location), self) )
		{
			//============================
			// ’µ’eƒGƒtƒFƒNƒg
			//============================
			if ( ShellDeflectEffectClass != None && (Level.NetMode != NM_DedicatedServer))
			{
				PlaySound( VehicleDeflectSound, , 5.5 * TransientSoundVolume, , , 1.5 );
				Spawn( ShellDeflectEffectClass, , , Location + HitNormal*16, rotator( HitNormal ) );
			}
			
			//Level.Game.Broadcast(self, "RMFWheeledVehicle Deflect");
			//============================
			// ’µ’eƒ`ƒFƒbƒN
			//============================
			if( HitCount < 2 && ( DeflectCheck( HitNormal, InAngleDegrees ) || ( bCannonShell && !bExplosiveAmmo ) || ( bCannonShell && bExplosiveAmmo && bDelayFuse && !bFuseFire ))  )
			{
				//============================
				// ’µ’eŽÀs
				//============================
				Deflect( HitNormal );
			}	
			//============================
			// ’µ’e‚µ‚È‚©‚Á‚½‚çÁ‹Ži’x‰„MŠÇ‚Ìˆ—‚ð“ü‚ê‚é—\’èj
			//============================
			else
			{
				//============================
				// ’x‰„MŠÇH
				//============================
				if( bDelayFuse )
				{
					//============================
					// ’x‰„MŠÇ”­“®‚µ‚Ä‚½‚ç’e‚ð‚»‚Ìê‚ÅŽ~‚ß‚é
					//============================
					if( bFuseFire )
					{
						//============================
						// ‚»‚Ìê‚ÅŽ~‚ß‚é
						//============================
						Velocity = vect(0, 0, 0);
						Speed = VSize(Velocity);
						
						//============================
						// Ž©—R—Ž‰º
						//============================
					    SetPhysics(PHYS_Falling);
					    bTrueBallistics = false;
					    Acceleration = PhysicsVolume.Gravity;
						
						return;
					}
				}
				else
				{
					//============================
					// HEAT‚È‚ç”š”­
					//============================
					if( AmmotType == AMMO_HEAT )
					{
						Explode(Location, HitNormal);
						return;
					}
					else
					{
//						if (Level.NetMode == NM_DedicatedServer)
//						{
//							bCollided = true;
//							SetCollision(False,False);
//						}
//						else
//						{
//							Destroy();
//						}	
						bCollided = true;						
						SetCollision(False,False);						
						Destroy();
					}
				}
			}
			return;
		}
		//============================
		// ŠÑ’Ê‚µ‚½‚çŠÑ’ÊƒGƒtƒFƒNƒgÄ¶
		//============================
		else
		{
			//Level.Game.Broadcast(self, "RMFWheeledVehicle Penetrate");
			
			//============================
			// ŠÑ’Ê‚µ‚½‚çŠÑ’ÊƒGƒtƒFƒNƒgÄ¶
			//============================
		 	if ( Level.NetMode != NM_DedicatedServer)
			{
			    PlaySound(VehicleHitSound,,5.5*TransientSoundVolume,,,1.5);
			    if ( EffectIsRelevant(Location,false) )
			    {
					Spawn( ShellHitVehicleEffectClass, , , Location, rotator( HitNormal ) );
			    }
			}
			
			//============================
			// ŠÑ’Ê‚µ‚½‚çŽÔ—¼‚Éƒ_ƒ[ƒW
			//============================
			if (Role == ROLE_Authority)
			{
				//============================
				// HEAT‚ÍŠp“x‚Åƒ_ƒ[ƒWŒƒŒ¸
				//============================
				if( AmmotType == AMMO_HEAT )
				{
					Damage *= GetPenetrationProbability( InAngleDegrees );
				}

				Wall.TakeDamage(Damage - 20 * (1 - VSize(Velocity) / default.Speed), instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
				MakeNoise(1.0);
			}

			//============================
			// ’x‰„MŠÇH
			//============================
			if( bDelayFuse )
			{
				//============================
				// ’x‰„MŠÇ”­“®‚µ‚Ä‚½‚ç’e‚ð‚»‚Ìê‚ÅŽ~‚ß‚é
				//============================
				if( bFuseFire )
				{
					//============================
					// ŠÑ’Ê”š”­—LŒø
					//============================
					
		    		bPenetrateExplode = true;
					//============================
					// ƒqƒbƒg‚µ‚½Actor‚ð•Û‘¶
					//============================
					PenetrateActor =  Wall;
					
					//============================
					// ‚»‚Ìê‚ÅŽ~‚ß‚é
					//============================
					SetLocation( Location + Normal(Velocity) * 80 );
					Velocity = vect(0, 0, 0);
					Speed = VSize(Velocity);
					
					//============================
					// Ž©—R—Ž‰º
					//============================
				    SetPhysics(PHYS_Falling);
				    bTrueBallistics = false;
				    Acceleration = PhysicsVolume.Gravity;
					return;
				}
			}
    		else
    		{			
    			//============================
				// ŠÑ’Ê‚µ‚½‚ç’e‚ðÁ‚·i’x‰„MŠÇ‚Ìˆ—‚ð“ü‚ê‚é—\’èj
				//============================
//				if (Level.NetMode == NM_DedicatedServer)
//				{
//					bCollided = true;
//					SetCollision(False,False);
//				}
//				else
//				{
//					Destroy();
//				}
				bCollided = true;						
				SetCollision(False,False);						
    			Destroy();
				return;
    		}
		}
	}
	
	//============================
	// HEAT’e‚Å‚È‚¯‚ê‚Î’µ’e‚¨‚æ‚ÑŠÑ’Êƒ`ƒFƒbƒN
	//============================
	if( DestroMesh == none && AmmotType != AMMO_HEAT  )
	{
		//============================
		// ŠÑ’Êƒ`ƒFƒbƒN
		//============================
		if( PenetrateCheck( HitNormal, InAngleDegrees ) )
	    {
			//============================
			// ŠÑ’Ê‚Å‚«‚½‚ç”²‚¯‚é
			//============================
	    	return;
	    }

		//============================
		// ’µ’eƒ`ƒFƒbƒN
		//============================
		if( DeflectCheck( HitNormal, InAngleDegrees ) )
		{
//			Level.Game.Broadcast(self, "DeflectCheck");

			//============================
			// ’µ’eŽÀs
			//============================
			Deflect( HitNormal );
			return;
		}
	}
	
	//============================
	// ƒqƒbƒgƒGƒtƒFƒNƒg
	//============================
	if ( Level.NetMode != NM_DedicatedServer != AmmotType == AMMO_HEAT )
	{
		Spawn( ImpactEffect,,, Location, rotator(-HitNormal) );
	}
	
	//============================
	// ‰ó‚ê‚éƒIƒuƒWƒFƒNƒg‚ª’e‚ðŽ~‚ß‚é‚©ƒ`ƒFƒbƒN
	//============================
//    if( DestroMesh != none && DestroMesh.bWontStopBullets )
//    {
//    	return;
//    }
	
	//============================
	// •Ç‚Éƒ_ƒ[ƒW
	//============================
	if (Role == ROLE_Authority)
	{
		
		if ( Mover(Wall) != None || DestroMesh != none || ROVehicleWeapon(Wall) != none)
			Wall.TakeDamage(Damage - 20 * (1 - VSize(Velocity) / default.Speed), instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
		MakeNoise(1.0);
	}

	//============================
	// HEAT’e‚Ìê‡
	//============================
	if( AmmotType == AMMO_HEAT )
	{
		//============================
		// Šp“x‚É‚æ‚Á‚ÄˆÐ—ÍŒ¸­
		//============================
		Damage *= GetPenetrationProbability( InAngleDegrees );
		
		//============================
		// ŠÑ’Êƒ`ƒFƒbƒN
		//============================
		if( !PenetrateCheck( HitNormal, InAngleDegrees ) )
		{
			//============================
			// ŠÑ’Ê‚µ‚È‚©‚Á‚½‚ç”š”­
			//============================
			Explode( Location, HitNormal );
		}
	}
	else
	{
		//============================
		// ’x‰„MŠÇ”­“®‚µ‚Ä‚½‚ç‚»‚Ìê‚ÉŽ~‚ß‚é
		//============================
		if( bDelayFuse )
		{
			if( bFuseFire )
			{
				//============================
				// ‚»‚Ìê‚ÅŽ~‚ß‚é
				//============================
				SetLocation( Location );
				Velocity = vect(0, 0, 0);
				Speed = VSize(Velocity);
				
				//============================
				// Ž©—R—Ž‰º
				//============================
			    SetPhysics(PHYS_Falling);
			    bTrueBallistics = false;
			    Acceleration = PhysicsVolume.Gravity;
				return;
			}
		}
		
		//============================
		// ÅŒã‚Ííœ
		//============================
//		if (Level.NetMode == NM_DedicatedServer)
//		{
//			bCollided = true;
//			SetCollision(False,False);
//		}
//		else
//		{
//			Destroy();
//		}
		bCollided = true;						
		SetCollision(False,False);						
		Destroy();
	}
}


//=============================================================================
// ProcessTouch - We hit something, so damage it if it's a player
//=============================================================================
simulated function ProcessTouch(Actor Other, Vector HitLocation)
{
	local Vector	X, Y, Z;
	local float	V;
	local bool	bHitWhipAttachment;
	local ROPawn HitPawn;
	local ROVehicle HitVehicle;
	local ROVehicleWeapon HitVehicleWeapon;
	local bool bHitVehicleDriver;
	local Vector TempHitLocation, HitNormal;
	local array<int>	HitPoints;
	local int i;
	local float 					PenetrationPower;	// ŠÑ’Ê—Íimmj
	local float						PowerFallMag;		// ƒpƒ[ƒ_ƒEƒ“”{—¦

	local float InAngle;
    local float InAngleDegrees;
//	local Vector VNorm;

	local vector TraceHitLocation, HitNormal2;
    Trace(TraceHitLocation, HitNormal2, HitLocation + Normal(Velocity) * 50, HitLocation - Normal(Velocity) * 50, True);
    GetAxes(rotator(HitNormal2),X,Y,Z);
	InAngle= Acos(Normal(-Normal(Velocity)) dot Normal(X));
	InAngleDegrees = Abs(90-(InAngle * 57.2957795131));
	
//	DrawStayingDebugLine( TraceHitLocation, TraceHitLocation+(HitNormal2*50), 0, 255, 0);
//	DrawStayingDebugLine( TraceHitLocation-(Normal(Velocity)*50), TraceHitLocation, 255, 0, 0);
//	VNorm = (Normal(Velocity) dot HitNormal2) * HitNormal2;
//	DrawStayingDebugLine( Location, Location-( (-HitNormal2 + 2.0f *  VNorm )*20), 0, 255, 0);

//	Level.Game.Broadcast(self, "InAngleDegrees="$InAngleDegrees);
	//============================
	// ’x‰„MŠÇ”­“®Ï‚Ý‚È‚ç”²‚¯‚é
	//============================
	if( bFuseFire )
	{
		return;
	}
	
	//------------------------
	// 
	//------------------------
	if (Other == Instigator || Other.Base == Instigator || !Other.bBlockHitPointTraces || Instigator == None)
		return;

	//============================
	// ƒqƒbƒg”ƒAƒbƒv
	//============================
	HitCount++;

	//============================
	// ŽÔ—¼‹y‚ÑŽÔ—¼•Ší‚É•ÏŠ·
	//============================
	HitVehicleWeapon = ROVehicleWeapon(Other);
	HitVehicle = ROVehicle(Other.Base);

	//============================
	// ƒhƒ‰ƒCƒo[‚ÉÕŒ‚
	//============================
	if( Level.NetMode != NM_DedicatedServer )
	{
		if( HitVehicle != none )
		{
			ShakeDriver( HitVehicle.Controller );
			
	        for( i = 0; i < HitVehicle.WeaponPawns.Length; i++)
	        {
	        	if( HitVehicle.WeaponPawns[i] != none )
	        	{
	        		//Level.Game.Broadcast(self, "Cont="$ROVehicle(Wall).WeaponPawns[i].Controller);
					ShakeDriver( HitVehicle.WeaponPawns[i].Controller );
				}
	        }
		}
	}
	//============================
	// ŽÔ—¼H
	//============================
    if( HitVehicleWeapon != none && HitVehicle != none )
    {
		//============================
		// ”š”­‚·‚é’e‚©‚Ç‚¤‚©
		//============================
		if( bExplosiveAmmo )
		{
			//============================
			// ’x‰„MŠÇ?
			//============================
			if( bDelayFuse )
			{
				LastHitNormal = HitNormal2;
				
				//============================
				// ’x‰„MŠÇì“®
				//============================
				SetTimer( FuseTime, false );
				bFuseFire = true;
			}
			//============================
			// ’…”­‚È‚ç‚·‚®”š”­
			//============================
			else
			{
				//Level.Game.Broadcast(self, "Explode");
				if( AmmotType != AMMO_HEAT )
				{
					Explode(Location, HitNormal2);
					return;
				}
			}
		}	

    	//============================
		// 
		//============================
		if ( HitVehicleWeapon.HitDriverArea(HitLocation, Velocity) )
		{
			if( HitVehicleWeapon.HitDriver(HitLocation, Velocity) )
			{
				bHitVehicleDriver = true;
			}
			else
			{
				return;
			}
		}

		//============================
		// ŽÔ—¼•Ší
		//============================
	    if( HitVehicleWeapon.IsA('ROVehicleWeapon') )
    	{
    		
			//============================
			// íŽÔ
			//============================
		    if( HitVehicle.IsA('RMFTreadCraft') )
			{
				//============================
				// –C“ƒŠÑ’Êƒ`ƒFƒbƒN
				//============================
	    		if(!RMFTreadCraft(HitVehicle).ShouldThreatPenetrate(HitVehicleWeapon, HitLocation, Normal(Velocity), GetPenetrationNumber(LaunchLocation-HitLocation), self) )//‚±‚±‚Åƒqƒbƒgƒ`ƒFƒbƒN)
			    {
					//============================
					// ƒGƒtƒFƒNƒgÄ¶
					//============================
					if (ShellDeflectEffectClass != None && (Level.NetMode != NM_DedicatedServer))
					{
						PlaySound(VehicleDeflectSound,,5.5*TransientSoundVolume,,,1.5);
						Spawn(ShellDeflectEffectClass,,, Location + HitNormal2*16,rotator(HitNormal2));
					}
					//============================
					// ’µ’eƒ`ƒFƒbƒN
					//============================
					if( HitCount < 2 && ( DeflectCheck( HitNormal2, InAngleDegrees ) || ( bCannonShell && !bExplosiveAmmo ) || ( bCannonShell && bExplosiveAmmo && bDelayFuse && !bFuseFire ) ) )
					{

						//============================
						// ’µ’eŽÀs
						//============================
						Deflect( HitNormal2 );
//						Level.Game.Broadcast(self, "Deflect");

					}	
					//============================
					// ’µ’e‚µ‚È‚©‚Á‚½‚çÁ‹Ži’x‰„MŠÇ‚Ìˆ—‚ð“ü‚ê‚é—\’èj
					//============================
					else
					{
						//============================
						// ’x‰„MŠÇH
						//============================
						if( bDelayFuse )
						{
							//============================
							// ’x‰„MŠÇ”­“®‚µ‚Ä‚½‚ç’e‚ð‚»‚Ìê‚ÅŽ~‚ß‚é
							//============================
							if( bFuseFire )
							{
								//============================
								// ‚»‚Ìê‚ÅŽ~‚ß‚é
								//============================
								Velocity = vect(0, 0, 0);
								Speed = VSize(Velocity);
								
								//============================
								// Ž©—R—Ž‰º
								//============================
							    SetPhysics(PHYS_Falling);
							    bTrueBallistics = false;
							    Acceleration = PhysicsVolume.Gravity;
//								Level.Game.Broadcast(self, "NoDeflect");
							}
							return;
						}
						else
						{
							//============================
							// HEAT‚È‚ç”š”­
							//============================
							if( AmmotType == AMMO_HEAT )
							{
								Explode(Location, HitNormal2);
								return;
							}
							else
							{
//								if (Level.NetMode == NM_DedicatedServer)
//								{
//									bCollided = true;
//									SetCollision(False,False);
//								}
//								else
//								{
//									Destroy();
//								}	
								bCollided = true;						
								SetCollision(False,False);						
								Destroy();
							}
						}
					}
			    	return;
			    }
			 	else 
		    	{
					//============================
					// ŠÑ’Ê‚µ‚½‚çŠÑ’ÊƒGƒtƒFƒNƒgÄ¶
					//============================
		    		if ( Level.NetMode != NM_DedicatedServer)
					{
					    PlaySound(VehicleHitSound,,5.5*TransientSoundVolume,,,1.5);
					    if ( EffectIsRelevant(Location,false) )
					    {
							Spawn(ShellHitVehicleEffectClass,,,HitLocation,rotator(HitNormal2));
					    }
					}
					//============================
					// ŠÑ’Ê‚µ‚½‚çŽÔ—¼•Ší‚É‚Éƒ_ƒ[ƒW
					//============================
					if (Role == ROLE_Authority)
					{
						//============================
						// HEAT‚ÍŠp“x‚Åƒ_ƒ[ƒWŒƒŒ¸
						//============================
						if( AmmotType == AMMO_HEAT )
						{
							Damage *= GetPenetrationProbability( InAngleDegrees );
						}
						
						if ( bHitVehicleDriver )
						{
							HitVehicleWeapon.TakeDamage(Damage - 20 * (1 - VSize(Velocity) / default.Speed), instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
						}
						else
						{
							HitVehicle.TakeDamage(Damage - 20 * (1 - VSize(Velocity) / default.Speed), instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
						}
						MakeNoise(1.0);
					}

					//============================
					// ŠÑ’Ê‚µ‚½‚ç’e‚ðÁ‚·i’x‰„MŠÇ‚Ìˆ—‚ð“ü‚ê‚é—\’èj
					//============================
					//============================
					// ’x‰„MŠÇH
					//============================
					if( bDelayFuse )
					{
						//============================
						// ’x‰„MŠÇ”­“®‚µ‚Ä‚½‚ç’e‚ð‚»‚Ìê‚ÅŽ~‚ß‚é
						//============================
						if( bFuseFire )
						{
				    		bPenetrateExplode = true;
							PenetrateActor =  Other.Base;
							
							//============================
							// ‚»‚Ìê‚ÅŽ~‚ß‚é
							//============================
							SetLocation( Location + Normal(Velocity) * 80 );
							Velocity = vect(0, 0, 0);
							Speed = VSize(Velocity);
							
							//============================
							// Ž©—R—Ž‰º
							//============================
						    SetPhysics(PHYS_Falling);
						    bTrueBallistics = false;
						    Acceleration = PhysicsVolume.Gravity;
							
							return;
						}
					}
		    		else
		    		{
//						if (Level.NetMode == NM_DedicatedServer)
//						{
//							bCollided = true;
//							SetCollision(False,False);
//						}
//						else
//						{
//							Destroy();
//						}
						bCollided = true;						
						SetCollision(False,False);						
		    			Destroy();
		    		}
			    	return;
		    	}
			}
			//============================
			// ƒ^ƒCƒ„•t‚«ŽÔ—¼
			//============================
	    	else if( HitVehicle.IsA('RMFWheeledVehicle') )
			{
				//============================
				// –C“ƒŠÑ’Êƒ`ƒFƒbƒN
				//============================
	    		if(!RMFWheeledVehicle(HitVehicle).ShouldThreatPenetrate(HitVehicleWeapon, HitLocation, Normal(Velocity), GetPenetrationNumber(LaunchLocation-HitLocation), self) )//‚±‚±‚Åƒqƒbƒgƒ`ƒFƒbƒN)
			    {
					//============================
					// ƒGƒtƒFƒNƒgÄ¶
					//============================
					if (ShellDeflectEffectClass != None && (Level.NetMode != NM_DedicatedServer))
					{
				        PlaySound(VehicleDeflectSound,,5.5*TransientSoundVolume,,,1.5);
						Spawn(ShellDeflectEffectClass,,, Location + HitNormal2*16,rotator(HitNormal2));
					}
					//============================
					// ’µ’eƒ`ƒFƒbƒN
					//============================
					if( HitCount < 2 && ( DeflectCheck( HitNormal2, InAngleDegrees ) || ( bCannonShell && !bExplosiveAmmo ) || ( bCannonShell && bExplosiveAmmo && bDelayFuse && !bFuseFire ) ) )
					{
						//============================
						// ’µ’eŽÀs
						//============================
						Deflect( HitNormal2 );
	//						Level.Game.Broadcast(self, "Deflect");
					}	
					//============================
					// ’µ’e‚µ‚È‚©‚Á‚½‚çÁ‹Ži’x‰„MŠÇ‚Ìˆ—‚ð“ü‚ê‚é—\’èj
					//============================
					else
					{
						//============================
						// ’x‰„MŠÇH
						//============================
						if( bDelayFuse )
						{
							//============================
							// ’x‰„MŠÇ”­“®‚µ‚Ä‚½‚ç’e‚ð‚»‚Ìê‚ÅŽ~‚ß‚é
							//============================
							if( bFuseFire )
							{
								//============================
								// ‚»‚Ìê‚ÅŽ~‚ß‚é
								//============================
								Velocity = vect(0, 0, 0);
								Speed = VSize(Velocity);
								
								//============================
								// Ž©—R—Ž‰º
								//============================
							    SetPhysics(PHYS_Falling);
							    bTrueBallistics = false;
							    Acceleration = PhysicsVolume.Gravity;
//								Level.Game.Broadcast(self, "NoDeflect");
							}
							return;
						}
						else
						{
							//============================
							// HEAT‚È‚ç”š”­
							//============================
							if( AmmotType == AMMO_HEAT )
							{
								Explode(Location, HitNormal2);
								return;
							}
							else
							{
//								if (Level.NetMode == NM_DedicatedServer)
//								{
//									bCollided = true;
//									SetCollision(False,False);
//								}
//								else
//								{
//									Destroy();
//								}	
								bCollided = true;						
								SetCollision(False,False);						
								Destroy();
							}
						}
					}
			    	return;
			    }
			 	else 
		    	{
					//============================
					// ŠÑ’Ê‚µ‚½‚çŠÑ’ÊƒGƒtƒFƒNƒgÄ¶
					//============================
		    		if ( Level.NetMode != NM_DedicatedServer)
					{
					    PlaySound(VehicleHitSound,,5.5*TransientSoundVolume,,,1.5);
					    if ( EffectIsRelevant(Location,false) )
					    {
							Spawn(ShellHitVehicleEffectClass,,,HitLocation,rotator(HitNormal2));
					    }
					}
					//============================
					// ŠÑ’Ê‚µ‚½‚çŽÔ—¼•Ší‚É‚Éƒ_ƒ[ƒW
					//============================
					if (Role == ROLE_Authority)
					{
						//============================
						// HEAT‚ÍŠp“x‚Åƒ_ƒ[ƒWŒƒŒ¸
						//============================
						if( AmmotType == AMMO_HEAT )
						{
							Damage *= GetPenetrationProbability( InAngleDegrees );
						}
						if ( bHitVehicleDriver )
						{
							HitVehicleWeapon.TakeDamage(Damage - 20 * (1 - VSize(Velocity) / default.Speed), instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
						}
						else
						{
							HitVehicle.TakeDamage(Damage - 20 * (1 - VSize(Velocity) / default.Speed), instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
						}
						MakeNoise(1.0);
					}

					//============================
					// ŠÑ’Ê‚µ‚½‚ç’e‚ðÁ‚·i’x‰„MŠÇ‚Ìˆ—‚ð“ü‚ê‚é—\’èj
					//============================
					//============================
					// ’x‰„MŠÇH
					//============================
					if( bDelayFuse )
					{
						//============================
						// ’x‰„MŠÇ”­“®‚µ‚Ä‚½‚ç’e‚ð‚»‚Ìê‚ÅŽ~‚ß‚é
						//============================
						if( bFuseFire )
						{
				    		bPenetrateExplode = true;
							PenetrateActor =  Other.Base;
							
							//============================
							// ‚»‚Ìê‚ÅŽ~‚ß‚é
							//============================
							SetLocation( Location + Normal(Velocity) * 80 );
							Velocity = vect(0, 0, 0);
							Speed = VSize(Velocity);
							
							//============================
							// Ž©—R—Ž‰º
							//============================
						    SetPhysics(PHYS_Falling);
						    bTrueBallistics = false;
						    Acceleration = PhysicsVolume.Gravity;
							
							return;
						}
					}
		    		else
		    		{
//						if (Level.NetMode == NM_DedicatedServer)
//						{
//							bCollided = true;
//							SetCollision(False,False);
//						}
//						else
//						{
//							Destroy();
//						}
						bCollided = true;						
						SetCollision(False,False);						
		    			Destroy();
		    		
		    		}
			    	return;
	    		
		    	}
			}
 		
	    }



		if (Role == ROLE_Authority)
		{
			if ( bHitVehicleDriver )
			{
				HitVehicleWeapon.TakeDamage(Damage - 20 * (1 - VSize(Velocity) / default.Speed), instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
			}
			else
			{
				HitVehicle.TakeDamage(Damage - 20 * (1 - VSize(Velocity) / default.Speed), instigator, HitLocation, MomentumTransfer * Normal(Velocity), MyDamageType);
			}

			MakeNoise(1.0);
		}


        // Give the bullet a little time to play the hit effect client side before destroying the bullet
//		if (Level.NetMode == NM_DedicatedServer)
//		{
//			bCollided = true;
//			SetCollision(False,False);
//		}
//		else
//		{
//			Destroy();
//		}
		bCollided = true;						
		SetCollision(False,False);						
		Destroy();

        return;
    }

	//============================
	// ƒXƒs[ƒhƒ`ƒFƒbƒN
	//============================
	V = VSize(Velocity);
	if( V < 25 )
	{
		GetAxes(Rotation, X, Y, Z);
		V=default.Speed;
	}
	else
	{
	  	GetAxes(Rotator(Velocity), X, Y, Z);
	}

	//============================
	// l‘ÌilŠÔ‚ÌŽüˆÍj‚É’e‚ª“–‚½‚Á‚½‚©ƒ`ƒFƒbƒN
	//============================
 	if( ROBulletWhipAttachment(Other) != none )
	{
    	bHitWhipAttachment=true;

		//============================
		// l‘Ì‚Éƒqƒbƒg‚µ‚½‚©³Šm‚Éƒ`ƒFƒbƒN
		//============================
		Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (65535 * X), HitPoints, HitLocation,, 1);
		
		//============================
		// ˆê‰žƒqƒbƒgˆÊ’u‚É
		//============================
		SetLocation(TempHitLocation) ;

		//============================
		// ‚ ‚½‚Á‚Ä‚¢‚È‚©‚Á‚½‚ç”²‚¯‚¤r
		//============================
		if( Other == none )
		{	
			return;
		}
	
		//============================
		// ROPawn‚É•ÏŠ·
		//============================
		HitPawn = ROPawn(Other);
	
	}
	
	//============================
	// Œ ŒÀ‚ðŽ‚Á‚Ä‚¢‚é
	//============================
    if ( Role == ROLE_Authority )
    {
		//============================
		// ƒqƒbƒg‚µ‚Ä‚¢‚ê‚Îƒ_ƒ[ƒW‚ð—^‚¦‚é
		//============================
    	if ( HitPawn != none )
    	{

			HitPawn.ProcessLocationalDamage(Damage - 20 * (1 - V / default.Speed), Instigator, TempHitLocation, MomentumTransfer * X, MyDamageType,HitPoints);
    		
			//============================
			// ”š”­‚·‚é’e‚©‚Ç‚¤‚©
			//============================
			if( bExplosiveAmmo )
			{
				//============================
				// ’x‰„MŠÇ?
				//============================
				if( bDelayFuse )
				{
					LastHitNormal = HitNormal2;
					
					//============================
					// ’x‰„MŠÇì“®
					//============================
					SetTimer( FuseTime, false );
					bFuseFire = true;
				}
				//============================
				// ’…”­‚È‚ç‚·‚®”š”­
				//============================
				else
				{
//					Level.Game.Broadcast(self, "Explode");
					Explode(Location, HitNormal2);
					return;
				}
			}
    		
    		//============================
			// l‘ÌŠÑ’Ê‚ðƒ`ƒFƒbƒN
			//============================
			PenetrationPower = GetPenetrationNumber( LaunchLocation - Location ) * MagnificationTable[6] * PenetrationMag;
    		if( 15.0 < PenetrationPower)
    		{
				//============================
				// Ž©—R—Ž‰º‚³‚¹‚é
				//============================
			    SetPhysics(PHYS_Falling);
			    bTrueBallistics = false;
			    Acceleration = PhysicsVolume.Gravity;

				//============================
				// ƒpƒ[ƒ_ƒEƒ“
				//============================
    			PowerFallMag = ( DecrementTable[6] * 0.85 ) ;
    				
				//============================
				// ŠÑ’Ê—Í’á‰º
				//============================
				PenetrationMag *= PowerFallMag;
	    		Damage *= PenetrationMag;
    		}
    		else
    		{
				//============================
				// MŠÇì“®’†ˆÈŠO
				//============================
    			if( !bFuseFire )
    			{
					//============================
					// ŠÑ’Ê‚µ‚È‚©‚Á‚½‚çíœ
					//============================
					bCollided = true;						
					SetCollision(False,False);						
	    			Destroy();
    			}
    		}
    	}
    	else
    	{
			Other.TakeDamage(Damage - 20 * (1 - V / default.Speed), Instigator, HitLocation, MomentumTransfer * X, MyDamageType);
		}
	}
    	
	

//	if( !bHitWhipAttachment )
//		Destroy();
}

//=============================================================================
// ’x‰„MŠÇ
//=============================================================================
simulated function Timer()
{
	//============================
	// ’x‰„”š”­‚Ìê‡‚Í”ÍˆÍ+
	//============================
	if( DamageRadius != 0 )
	{
		DamageRadius *= 2.0;
	}
	
	//============================
	// ’x‰„”š”­
	//============================
//	Level.Game.Broadcast(self, "DelayExplode");
	Explode( Location, LastHitNormal );

}


//=============================================================================
// ShakeDriver
//=============================================================================
simulated function ShakeDriver( Controller CNT )
{
	local PlayerController PC;
	local float tmp0,tmp1,tmp2,tmp3,tmp4;
	local Vector V;
	
	if( PlayerController(CNT) != None )
	{
		PC = PlayerController(CNT);
		tmp0 = PenetrationTable[0];
		tmp1 = tmp0 / 20;
		tmp2 = tmp0 / 30;
		tmp3 = tmp0 / 160;
		tmp4 = tmp0 / 40;
		V = Normal(Velocity);
		
		PC.ShakeView(V * tmp0, V * tmp1, tmp3, V * tmp2, V * tmp0, tmp3*2);
		ROPlayer(PC).AddBlur(tmp4,1);
	}

}

//=============================================================================
// ’›’e
//=============================================================================
simulated function Deflect(vector HitNormal)
{
	local vector VNorm;		// ”½ŽËƒxƒNƒgƒ‹
	local float InAngle;
    local vector X,Y,Z;
    local float InAngleDegrees;

	//============================
	// “üŽËŠp‚ð‹‚ß‚é
	//============================
    GetAxes(rotator(HitNormal),X,Y,Z);
	InAngle= Acos(Normal(-Normal(Velocity)) dot Normal(X));
	InAngleDegrees = Abs(90-(InAngle * 57.2957795131));

	//============================
	// ƒAƒ“ƒrƒGƒ“ƒgƒTƒEƒ“ƒhOFF
	//============================
	AmbientSound=none;

	//============================
	// ”½ŽË•ûŒüŽæ“¾
	//============================
	VNorm = (Velocity dot HitNormal) * HitNormal;
	if( InAngleDegrees > 80.0 || !bCannonShell )
	{
		VNorm = VNorm + VRand()*FRand()*8000;  //Spread
	}
	Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;
	
//	SetLocation( Location + ( Velocity * 0.01 ));
//	DrawStayingDebugLine( Location, Location+(Normal(Velocity)*50), 0, 255, 255);

	//============================
	// ƒXƒs[ƒhÝ’è
	//============================
	Speed = VSize(Velocity);

	//============================
	// ”½ŽËƒGƒtƒFƒNƒgÄ¶
	//============================
    if (Level.NetMode != NM_DedicatedServer )
    {
    	if( DeflectEffect != none )
    	{
	    	Spawn(DeflectEffect,,, Location, Rotator(-HitNormal));
    	}
    	
		//============================
		// ‘åŒûŒa
		//============================
//		if( bCannonShell )
//		{
//			ImpactEffectLarge( Location, HitNormal );
//		}
//    	else
//    	{
//	        if ( EffectIsRelevant(Location,false) )
//	        {
//	        	Spawn(class'RMFBulletDeflectEffect',,, Location, Rotator(-HitNormal));
//	        	//Spawn(ShellDeflectEffectClass,,,Location + HitNormal*16,rotator(HitNormal));
//	        }
//    	}
		//PlaySound(VehicleDeflectSound,,5.5*TransientSoundVolume);
    }

	//============================
	// ƒqƒbƒgŒã‚Ìƒ‚ƒfƒ‹‚ª—L‚é‚È‚çÝ’è
	//============================
    if( bTracer && StaticMesh != DeflectedMesh )
    {
    	SetStaticMesh(DeflectedMesh);
    }

	//============================
	// Ž©—R—Ž‰º‚³‚¹‚é
	//============================
    SetPhysics(PHYS_Falling);
    bTrueBallistics = false;
	Acceleration = PhysicsVolume.Gravity;
}

//=============================================================================
// ’µ’eƒ`ƒFƒbƒN
//=============================================================================
simulated function bool DeflectCheck( vector HitNormal, float AOI  )
{

	local Vector			InciVec;			// “üŽËƒxƒNƒgƒ‹
	local Vector			HitLoc;				// ŠÑ’ÊæêŠ
	local Vector			HitNormal2;			// ƒqƒbƒg–@ü
	local ESurfaceTypes		ST;					// ÞŽ¿ƒ^ƒCƒv
	local Material			HitMat;				// ŠÑ’ÊæÞŽ¿
	local float				Angle;
	
	//============================
	// ÅIƒqƒbƒgˆÊ’u‚ð•Û‘¶
	//============================
	LastHit = Location;
	
	//============================
	// ’µ’e‚Íˆê‰ñ‚¾‚¯
	//============================
	if ( HitCount < 2 )
	{
		//============================
		// “üŽËƒxƒNƒgƒ‹
		//============================
	 	InciVec = Vector( Rotation );
	 	
		//============================
		// ƒqƒbƒg‚µ‚½êŠ‚ÌÞŽ¿‚ðŽæ“¾
		//============================
		Trace( HitLoc, HitNormal2, Location + Vector( Rotation ) * 16, Location, false,, HitMat);
		
		//============================
		// •Ç‚ÌÞŽ¿‚ð”»•Ê
		//============================
		if (HitMat == None)
			ST = EST_Default;
		else
			ST = ESurfaceTypes(HitMat.SurfaceType);

		//============================
		// ’l‚ªƒ}ƒCƒiƒX‚ÌŽž‚Í’²®
		//============================
		if( AOI < 0 )
		{
			AOI = 90.0 +  AOI;
		}
		
		//============================
		// ”½ŽË‚Å‚«‚éŠp“x‚ðŽæ“¾
		//============================
		Angle = DeflectMinimumAngle[AmmotType] - ( MagnificationTable[ST] * 10 );
//		Level.Game.Broadcast(self, "Deflect" );

		//============================
		// ’µ’e‚·‚é‚©‚ðƒ`ƒFƒbƒN
		//============================
		if( AOI < Angle || bTracer )
		{
			PenetrationMag *= DecrementTable[ST];	// ŠÑ’Ê—Í‚ð’á‰º‚³‚¹‚é
			PenetrationMag *= DeflectDecrement[AmmotType];	// ŠÑ’Ê—Í‚ð’á‰º‚³‚¹‚é
			return true;
		}
	}
	return false;
}


//=============================================================================
// ŠÑ’Êƒ`ƒFƒbƒN
//=============================================================================
simulated function bool PenetrateCheck( vector HitNormal, float AOI  )
{

	local Actor 					Result;				// ŠÑ’ÊæActor
	local Vector					InciVec;			// “üŽËƒxƒNƒgƒ‹
	local Vector					OutLoc;				// ŠÑ’ÊæêŠ
	local Vector					OutNormal;			// ŠÑ’Êæ–@ü
	local Vector					Distance;			// ”­ŽËêŠ‚©‚ç‚Ì‹——£
	local float 					Thickness;			// •Ç‚ÌŒú‚³
	local float 					PenetrationPower;	// ŠÑ’Ê—Íimmj
	local float						PowerFallMag;		// ƒpƒ[ƒ_ƒEƒ“”{—¦
	local ROBulletWhipAttachment	BWA;				// Pawn“–‚½‚è”»’èƒ`ƒFƒbƒN—p
	local Material HitMat;								// ÞŽ¿ƒgƒŒ[ƒX—p
	local ESurfaceTypes				ST1, ST2, ST3;		// ÞŽ¿ƒ^ƒCƒv(•\E— EÅI“I‚È)
	
	//============================
	// ÅIƒqƒbƒgˆÊ’u‚ð•Û‘¶
	//============================
	LastHit = Location;
	
	//============================
	// “üŽËƒxƒNƒgƒ‹
	//============================
 	InciVec = Vector( Rotation );
	
	//============================
	// ”­ŽËˆÊ’u‚©‚ç‚Ì‹——£
	//============================
 	Distance = LaunchLocation - Location;
 	
	//============================
	// –Ú‚Ì‘O‚ÌÞŽ¿‚ðƒ`ƒFƒbƒN
	//============================
	Trace( OutLoc, OutNormal, Location + InciVec * 16, Location, false,, HitMat );	
	
	//============================
	// •Ç‚ÌÞŽ¿‚ð”»•Ê
	//============================
	if (HitMat == None)
		ST1 = EST_Default;
	else
		ST1 = ESurfaceTypes( HitMat.SurfaceType );

	//============================
	// ŠÑ’Ê‚Å‚«‚éŒú‚³‚ðŒvŽZ
	//============================
	PenetrationPower = GetPenetrationNumber( Distance ) * MagnificationTable[ST1] * GetPenetrationProbability(AOI) * PenetrationMag;
//	Level.Game.Broadcast(self, "PenetrationPower="$PenetrationPower);
	
	//============================
	// — ‘¤‚ðƒgƒŒ[ƒXƒ`ƒFƒbƒN
	//============================
//	Spawn(class'RMFEngine.DebugArrow', self, ,OutLoc + InciVec * 50, rotator(-InciVec));	
//	Spawn(class'RMFEngine.DebugArrow', self, ,OutLoc + InciVec * 100, rotator(InciVec));	
	
	Result=Trace( OutLoc, OutNormal, OutLoc , OutLoc + InciVec * 50 , false,,HitMat );
//	Level.Game.Broadcast(self, "Result="$Result);
//	Spawn(class'RMFEngine.DebugArrow', self, ,OutLoc, rotator(-InciVec));	
	
	//============================
	// ŠÑ’Ê¬Œ÷‚µ‚½‚ç— ‚ÌÞŽ¿ƒ`ƒFƒbƒN
	//============================
	if( Result != None )
	{
		//============================
		// •Ç‚ÌÞŽ¿‚ð”»•Ê
		//============================
		if (HitMat == None)
			ST2 = EST_Default;
		else
			ST2 = ESurfaceTypes(HitMat.SurfaceType);

		//============================
		// ŒÅ‚¢•û‚É‡‚í‚¹‚é
		//============================
		if( MagnificationTable[ST1] > MagnificationTable[ST2] )
		{
			ST3 = ST1;
		}
		else
		{
			ST3 = ST2;
		}
		
		
//		Level.Game.Broadcast(self, "Magnification="$Penetration$" Damage="$Damage);
//		Level.Game.Broadcast(self, "ST1="$ST1$" ST2="$ST2);
		

		//============================
		// ŠÑ’Ê‚Å‚«‚éŒú‚³‚ðÄŒvŽZ
		//============================
		PenetrationPower = GetPenetrationNumber( Distance ) * MagnificationTable[ST3] * GetPenetrationProbability(AOI) * PenetrationMag;

		//Spawn(class'RMFEngine.DebugArrow', self, ,Location, rotator(InciVec));
		//Spawn(class'RMFEngine.DebugSphere', self, ,Location + InciVec * PenetrationPower, );
		//Spawn(class'RMFEngine.DebugArrow', self, ,OutLoc,  rotator(-InciVec));

		//============================
		// •Ç‚ÌŒú‚³‚ðŒvŽZ
		//============================
		Thickness = (VSize( OutLoc - Location )) / 52.48 * 100;
		//Level.Game.Broadcast(self, "Penetration="$Penetration);
		//Level.Game.Broadcast(self, "Tickness="$Thickness$" mm PenetrationPower="$PenetrationPower$"mm");
//		Level.Game.Broadcast(self, "PenetrationPower="$PenetrationPower$" Damage="$Damage);
		
		//============================
		// ŠÑ’Ê—Í‚ªŸ‚Á‚Ä‚¢‚½‚çŠÑ’Ê
		//============================
		//Level.Game.Broadcast(self, "Result="$Result);
		if( Thickness < PenetrationPower && Thickness > 0 )
		{
			//============================
			// ‚Ç‚ê‚¾‚¯ƒpƒ[ƒ_ƒEƒ“‚·‚é‚©
			//============================
			PowerFallMag = DecrementTable[ST3] * GetPenetrationProbability(AOI) * (1 - ( Thickness * 0.01 )) ;
			
			//============================
			// ŠÑ’Ê—Í‚Æƒ_ƒ[ƒWŒ»Û
			//============================
			PenetrationMag	*= PowerFallMag;
			Damage			*= PowerFallMag;
			
//			Level.Game.Broadcast(self, "Penetration="$Penetration$" Damage="$Damage);
			

	
			//============================
			// HEAT
			//============================
			if( AmmotType == AMMO_HEAT )
			{
//				Level.Game.Broadcast(self, "AMMO_HEAT="$PenetrationPower);
				//============================
				// •\‘¤”š”­@— ‘¤ƒ_ƒ[ƒW
				//============================
				Explode( Location, -HitNormal );
				DummyExplode( OutLoc, -OutNormal);
//				BlowUp( OutLoc);
				
				//============================
				// — ‘¤ƒGƒtƒFƒNƒgÄ¶
				//============================
//				if ( Level.NetMode != NM_DedicatedServer )
//				{
//					if ( ImpactEffect != None )
//					{				
//						Spawn( ImpactEffect,,, OutLoc, rotator( -OutNormal ) );
//					}
//				}
				return true;
			}

			//============================
			// ƒGƒtƒFƒNƒg‚ðÄ¶
			//============================
			if ( Level.NetMode != NM_DedicatedServer )
			{
				if ( ImpactEffect != None )
				{
					//============================
					// •\‘¤
					//============================
					Spawn( ImpactEffect,,, Location, rotator( -HitNormal ) );
					
					//============================
					// — ‘¤
					//============================
					Spawn( ImpactEffect,,, OutLoc, rotator( -OutNormal ) );
		 		}
			}

		
			//============================
			// ŠÑ’Êæ‚ÉˆÊ’u‚ð•ÏX
			//============================
	 		SetLocation(OutLoc + InciVec * 16) ;
			
			//============================
			// Ž©—R—Ž‰º
			//============================
		    SetPhysics(PHYS_Falling);
		    bTrueBallistics = false;
		    Acceleration = PhysicsVolume.Gravity;

			//============================
			// ŠÑ’ÊŒã‚Éˆê’Uƒ`ƒFƒbƒN
			//============================
			ForEach TouchingActors(class'ROBulletWhipAttachment', BWA)
			{
				ProcessTouch( BWA, Location );
			}
			
			//============================
			// ÅIƒqƒbƒgˆÊ’u‚Æ“¯‚¶ˆÊ’u‚È‚çfalse
			//============================
			if( LastHit == Location )
				return false;
			else
				return true;
		}
	}
	
	
	return false;
}

//=============================================================================
// ”š”­
//=============================================================================
simulated function Explode(vector HitLocation, vector HitNormal)
{
	local vector TraceHitLocation, TraceHitNormal;
	local Material HitMaterial;
	local ESurfaceTypes ST;
	local bool bShowDecal, bSnowDecal;

//	Level.Game.Broadcast(self, "Explode");

	Trace(TraceHitLocation, TraceHitNormal, Location + Vector(Rotation) * 16, Location, false,, HitMaterial);
	
    if (HitMaterial == None)
		ST = EST_Default;
	else
		ST = ESurfaceTypes(HitMaterial.SurfaceType);


    if ( EffectIsRelevant(Location,false) )
    {
		if( !PhysicsVolume.bWaterVolume )
		{
			Switch(ST)
			{
				case EST_Snow:
				case EST_Ice:
					Spawn(ExplosionSnowEffectClass,,,HitLocation + HitNormal*16,rotator(HitNormal));
					PlaySound(ExplosionSound[Rand(4)],,5.5*TransientSoundVolume);
					bShowDecal = true;
					break;
				case EST_Rock:
				case EST_Gravel:
				case EST_Concrete:
					Spawn(ExplosionRockEffectClass,,,HitLocation + HitNormal*16,rotator(HitNormal));
					PlaySound(ExplosionSound[Rand(4)],,5.5*TransientSoundVolume);
					bShowDecal = true;
					break;
				case EST_Wood:
				case EST_HollowWood:
					Spawn(ExplosionWoodEffectClass,,,HitLocation + HitNormal*16,rotator(HitNormal));
					PlaySound(ExplosionSound[Rand(4)],,5.5*TransientSoundVolume);
					bShowDecal = true;
					break;
				case EST_Water:
					Spawn(ExplosionWaterEffectClass,,,HitLocation + HitNormal*16,rotator(HitNormal));
					PlaySound(ExplosionSound[Rand(4)],,5.5*TransientSoundVolume);
					bShowDecal = false;
					break;
				default:
					Spawn(ExplosionDirtEffectClass,,,HitLocation + HitNormal*16,rotator(HitNormal));
					PlaySound(ExplosionSound[Rand(4)],,5.5*TransientSoundVolume);
					bShowDecal = true;
					break;
			}

	   		if ( bShowDecal && Level.NetMode != NM_DedicatedServer )
	   		{
	   			if( bSnowDecal && ExplosionDecalSnow != None)
				{
	   				Spawn(ExplosionDecalSnow,self,,Location, rotator(-HitNormal));
	   			}
	   			else if( ExplosionDecal != None)
				{
	   				Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
	   			}
	   		}
		}
    }
	        	
	
	if( bCollided )
		return;

	if( DamageRadius != 0 )
		BlowUp(HitLocation);

	// Save the hit info for when the shell is destroyed
	SavedHitLocation = HitLocation;
	SavedHitNormal = HitNormal;
	AmbientSound=none;

    bDidExplosionFX = true;

//	if (Level.NetMode == NM_DedicatedServer)
//	{
//		bCollided = true;
//		SetCollision(False,False);
//	}
//	else
//	{
//		bCollided = true;
//		Destroy();
//	}
	bCollided = true;						
	SetCollision(False,False);						
	Destroy();
}

//=============================================================================
// ”š”­
//=============================================================================
simulated function DummyExplode(vector HitLocation, vector HitNormal)
{
	local vector TraceHitLocation, TraceHitNormal;
	local Material HitMaterial;
	local ESurfaceTypes ST;
	local bool bShowDecal, bSnowDecal;
	
	Trace(TraceHitLocation, TraceHitNormal, Location + Vector(Rotation) * 16, Location, false,, HitMaterial);
	
    if (HitMaterial == None)
		ST = EST_Default;
	else
		ST = ESurfaceTypes(HitMaterial.SurfaceType);


    if ( EffectIsRelevant(Location,false) )
    {
		if( !PhysicsVolume.bWaterVolume )
		{
			Switch(ST)
			{
				case EST_Snow:
				case EST_Ice:
					Spawn(ExplosionSnowEffectClass,,,HitLocation + HitNormal*16,rotator(HitNormal));
					bShowDecal = true;
					break;
				case EST_Rock:
				case EST_Gravel:
				case EST_Concrete:
					Spawn(ExplosionRockEffectClass,,,HitLocation + HitNormal*16,rotator(HitNormal));
					bShowDecal = true;
					break;
				case EST_Wood:
				case EST_HollowWood:
					Spawn(ExplosionWoodEffectClass,,,HitLocation + HitNormal*16,rotator(HitNormal));
					bShowDecal = true;
					break;
				case EST_Water:
					Spawn(ExplosionWaterEffectClass,,,HitLocation + HitNormal*16,rotator(HitNormal));
					PlaySound(ExplosionSound[Rand(4)],,5.5*TransientSoundVolume);
					bShowDecal = false;
					break;
				default:
					Spawn(ExplosionDirtEffectClass,,,HitLocation + HitNormal*16,rotator(HitNormal));
					bShowDecal = true;
					break;
			}

	   		if ( bShowDecal && Level.NetMode != NM_DedicatedServer )
	   		{
	   			if( bSnowDecal && ExplosionDecalSnow != None)
				{
	   				Spawn(ExplosionDecalSnow,self,,Location, rotator(-HitNormal));
	   			}
	   			else if( ExplosionDecal != None)
				{
	   				Spawn(ExplosionDecal,self,,Location, rotator(-HitNormal));
	   			}
	   		}
		}
    }
	        	
	if( DamageRadius != 0 )
		BlowUp(HitLocation);
}


//=============================================================================
// íœ
//=============================================================================
simulated function Destroyed()
{
//	Level.Game.Broadcast(self, "Destroyed");
	if(mTracer != none)
	   mTracer.Destroy();
	if( Corona != none )
		Corona.destroy();

	Super.Destroyed();
}
//=============================================================================
// íŽÔ–C—p
//=============================================================================
// for tank cannon aiming. Returns the proper pitch adjustment to hit a target at a particular range
simulated static function int GetPitchForRange(int Range)
{
	local int i;

	if( !default.bMechanicalAiming )
		return 0;

	for (i = 0; i < default.MechanicalRanges.Length; i++)
	{
		if( default.MechanicalRanges[i].Range >= Range )
		{
			return default.MechanicalRanges[i].RangeValue;
		}
	}

	return 0;
}
//=============================================================================
// íŽÔ–C—p
//=============================================================================
simulated static function float GetYAdjustForRange(int Range)
{
	local int i;

	if( !default.bOpticalAiming )
		return 0;

	for (i = 0; i < default.OpticalRanges.Length; i++)
	{
		if( default.OpticalRanges[i].Range >= Range )
		{
			return default.OpticalRanges[i].RangeValue;
		}
	}

	return 0;
}

//=============================================================================
// ”š”­ƒ_ƒ[ƒW
//=============================================================================
function BlowUp(vector HitLocation)
{
	
	//============================
	// “à•”‚Å”š”­
	//============================
	if( bPenetrateExplode )
	{
		if( PenetrateActor != none )
		{
			PenetrateActor.TakeDamage(Damage, instigator, HitLocation, MomentumTransfer * Normal(Velocity), class'PenetrateExplosionDamage');
		}
	}
	else
	{
		HurtRadius(Damage, DamageRadius, MyExplosionDamageType, MomentumTransfer, HitLocation );
	}
	MakeNoise(1.0);
}

//=============================================================================
// defaultproperties
//=============================================================================

defaultproperties
{
     PenetrationMag=1.000000
     MagnificationTable(0)=2.200000
     MagnificationTable(1)=1.800000
     MagnificationTable(2)=2.100000
     MagnificationTable(3)=1.500000
     MagnificationTable(4)=33.500000
     MagnificationTable(5)=40.500000
     MagnificationTable(6)=3.000000
     MagnificationTable(7)=2.700000
     MagnificationTable(8)=11.800000
     MagnificationTable(9)=2.900000
     MagnificationTable(10)=2.500000
     MagnificationTable(11)=2.000000
     MagnificationTable(12)=1.900000
     MagnificationTable(13)=45.000000
     MagnificationTable(14)=7.600000
     MagnificationTable(15)=1.000000
     MagnificationTable(16)=50.000000
     MagnificationTable(17)=38.500000
     MagnificationTable(18)=3.200000
     MagnificationTable(19)=4.400000
     DecrementTable(0)=0.600000
     DecrementTable(1)=0.470000
     DecrementTable(2)=0.550000
     DecrementTable(3)=0.440000
     DecrementTable(4)=0.950000
     DecrementTable(5)=0.980000
     DecrementTable(6)=0.690000
     DecrementTable(7)=0.660000
     DecrementTable(8)=0.930000
     DecrementTable(9)=0.670000
     DecrementTable(10)=0.630000
     DecrementTable(11)=0.520000
     DecrementTable(12)=0.500000
     DecrementTable(13)=0.950000
     DecrementTable(14)=0.890000
     DecrementTable(15)=0.330000
     DecrementTable(16)=0.970000
     DecrementTable(17)=0.960000
     DecrementTable(18)=0.770000
     DecrementTable(19)=0.850000
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
     DeflectMinimumAngle(0)=30.000000
     DeflectMinimumAngle(1)=45.000000
     DeflectMinimumAngle(2)=34.500000
     DeflectMinimumAngle(3)=34.000000
     DeflectMinimumAngle(4)=35.000000
     DeflectMinimumAngle(5)=30.500000
     DeflectMinimumAngle(6)=20.000000
     DeflectMinimumAngle(7)=45.000000
     DeflectMinimumAngle(8)=20.000000
     DeflectDecrement(0)=0.500000
     DeflectDecrement(1)=0.700000
     DeflectDecrement(2)=0.600000
     DeflectDecrement(3)=0.300000
     DeflectDecrement(4)=0.300000
     DeflectDecrement(5)=0.300000
     DeflectDecrement(6)=0.200000
     DeflectDecrement(7)=0.500000
     DeflectDecrement(8)=0.200000
     ShellDeflectEffectClass=Class'ROEffects.ROBulletHitMetalArmorEffect'
     DampenFactor=0.500000
     DampenFactorParallel=0.200000
     DeflectEffect=Class'ROEffects.ROBulletHitEffect'
     VehicleDeflectSound=SoundGroup'ProjectileSounds.Bullets.Impact_Metal'
     VehicleHitSound=SoundGroup'ProjectileSounds.Bullets.Impact_Metal'
     ShellHitVehicleEffectClass=Class'ROEffects.ROBulletHitMetalEffect'
     ExplosionDirtEffectClass=Class'ROEffects.TankHEHitDirtEffect'
     ExplosionSnowEffectClass=Class'ROEffects.TankHEHitSnowEffect'
     ExplosionWoodEffectClass=Class'ROEffects.TankHEHitWoodEffect'
     ExplosionRockEffectClass=Class'ROEffects.TankHEHitRockEffect'
     ExplosionWaterEffectClass=Class'ROEffects.TankHEHitWaterEffect'
     Firsthit=True
     FuseTime=0.110000
     ExplosionSound(0)=SoundGroup'ProjectileSounds.cannon_rounds.OUT_HE_explode01'
     ExplosionSound(1)=SoundGroup'ProjectileSounds.cannon_rounds.OUT_HE_explode02'
     ExplosionSound(2)=SoundGroup'ProjectileSounds.cannon_rounds.OUT_HE_explode03'
     ExplosionSound(3)=SoundGroup'ProjectileSounds.cannon_rounds.OUT_HE_explode04'
     MyExplosionDamageType=Class'ROVehicles.HECannonShellDamage'
     DestroyTime=0.200000
     DamageRadius=0.000000
     ExplosionDecal=Class'ROEffects.ArtilleryMarkDirt'
     ExplosionDecalSnow=Class'ROEffects.ArtilleryMarkSnow'
}
