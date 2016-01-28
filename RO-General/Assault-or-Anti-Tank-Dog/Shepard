class Shepard extends Pawn;
//	Config(Shepard);

//Dynamit: this is the pawn class....
//removed config for now.
//#exec obj load file="RORU_Shepard_A.ukx" //package="RORU_Shepard"   //lets keep stuff outside /Dynamit!
//#exec obj load file="RORU_Shepard_A.uax" //package="RORU_Shepard"
//#exec obj load file="RORU_Shepard.ukx" //package="RORU_Shepard"   //lets keep stuff outside /Dynamit!
//#exec obj load file="RORU_Shepard.uax" //package="RORU_Shepard"
#exec OBJ LOAD FILE=..\Sounds\RORU_Shepard_snd.uax
#exec OBJ LOAD FILE=..\Textures\RORU_Shepard_tex.utx
#exec OBJ LOAD FILE=..\Animations\RORU_Shepard_anm.ukx


//#exec obj load file="RORU_Shepard_anm.ukx" package="RORU_Shepard_anm"   //lets keep stuff outside /Dynamit!
//#exec obj load file="RORU_Shepard_A.uax" //package="RORU_Shepard"
//#exec obj load file="RORU_Shepard.ukx" //package="RORU_Shepard"   //lets keep stuff outside /Dynamit!
//#exec obj load file="RORU_Shepard.uax" //package="RORU_Shepard"

//use anims meshes and sounds from externam package.....

//Dynamit: add ROBulletWhip Attchmnt
// Collision
var		ROBulletWhipAttachment  AuxCollisionCylinder;   // Additional collision cylinder for detecting bullets passing by
var 				bool 		SavedAuxCollision;     	// Saved aux collision cylinder status

//var() config int HitDamage,SentryHealth;

var() int HitDamage,SentryHealth;

var(Sounds) Sound VoicesList[16],FiringSounds[5];
var Pawn OwnerPawn;  //Dog owner, aka Dynamit :)
var byte RepAnimationAction,ClientAnimNum;
var vector RepHitLocation;
var transient float NextVoiceTimer;
var ShepardGun WeaponOwner;
var transient Font HUDFontz[2];



replication
{
	// Variables the server should send to the client.    //DYnamit: remove uneeded stuff.
	reliable if( Role==ROLE_Authority )
		RepAnimationAction,RepHitLocation, SentryHealth;
}







final function SetOwningPlayer( Pawn Other, ShepardGun W )
{
	OwnerPawn = Other;
	PlayerReplicationInfo = Other.PlayerReplicationInfo;
	WeaponOwner = W;
}


simulated function PostRender2D(Canvas C, float ScreenLocX, float ScreenLocY)
{
	local string S;
	local float XL,YL;
	local vector D;

	if( Health<=0 || PlayerReplicationInfo==None )
		return; // Dead or unknown owner.
	D = C.Viewport.Actor.CalcViewLocation-Location;
	if( (vector(C.Viewport.Actor.CalcViewRotation) Dot D)>0 )
		return; // Behind the camera
	XL = VSizeSquared(D);
	if( XL>1440000.f || !FastTrace(C.Viewport.Actor.CalcViewLocation,Location) )
		return; // Beyond 1200 distance or not in line of sight.

	if( C.Viewport.Actor.PlayerReplicationInfo==PlayerReplicationInfo )
		C.SetDrawColor(0,200,0,255);
	else C.SetDrawColor(200,0,0,255);

	// Load up fonts if not yet loaded.
	if( Default.HUDFontz[0]==None )
	{
		Default.HUDFontz[0] = Font(DynamicLoadObject("ROFonts_Rus.ROArial7",Class'Font'));
		if( Default.HUDFontz[0]==None )
			Default.HUDFontz[0] = Font'Engine.DefaultFont';
		Default.HUDFontz[1] = Font(DynamicLoadObject("ROFonts_Rus.ROBtsrmVr12",Class'Font'));
		if( Default.HUDFontz[1]==None )
			Default.HUDFontz[1] = Font'Engine.DefaultFont';
	}


	if( C.ClipY<1024 )
		C.Font = Default.HUDFontz[0];
	else C.Font = Default.HUDFontz[1];

	C.Style = ERenderStyle.STY_Alpha;
	S = "Owner:"@PlayerReplicationInfo.PlayerName;
	C.TextSize(S,XL,YL);
	C.SetPos(ScreenLocX-XL*0.5,ScreenLocY-YL*2.f);
	C.DrawTextClipped(S,false);
	S = "Health:"@Max(1,float(Health)/float(SentryHealth)*100.f)@"%";
	C.TextSize(S,XL,YL);
	C.SetPos(ScreenLocX-XL*0.5,ScreenLocY-YL*0.75f);
	C.DrawTextClipped(S,false);
}

event PostBeginPlay()
{
	Super.PostBeginPlay();

    //AssignInitialPose();

    //UpdateShadow();


	if (  AuxCollisionCylinder == none )
	{
		AuxCollisionCylinder = Spawn(class 'ROBulletWhipAttachment',self);
		AttachToBone(AuxCollisionCylinder, 'spine');
	}

    SavedAuxCollision = AuxCollisionCylinder.bCollideActors;

	TweenAnim(IdleRestAnim,0.01f);
	if ( (ControllerClass != None) && (Controller == None) )
		Controller = spawn(ControllerClass);
	if ( Controller != None )
		Controller.Possess(self);
	Health = SentryHealth;
}



simulated function PostNetBeginPlay()
{
	Super.PostNetBeginPlay();
	RepHitLocation = vect(0,0,0);
	if( Level.NetMode==NM_Client )
	{
		bNetNotify = true;
		PostNetReceive();
		if( RepAnimationAction==0 )
			TweenAnim(IdleRestAnim,0.01f);
	}
}
simulated function PostNetReceive()
{
	if( ClientAnimNum!=RepAnimationAction )
		SetAnimationNum(RepAnimationAction);
	if( RepHitLocation!=vect(0,0,0) )
	{
		RepHitLocation = vect(0,0,0);
	}
}

simulated function Destroyed()
{
	if( Controller!=None )
	{
		Controller.bIsPlayer = false;
		Controller.Destroy();
	}
}
simulated function SetAnimationNum( byte Num )
{
	RepAnimationAction = Num;
	switch( Num )
	{
	case 0:
		if( ClientAnimNum==1 )
		{
			if( Level.NetMode!=NM_Client )
				Speech(0);
			PlayAnim('Idle');
		}
		else PlayAnim('Idle');
		if( Level.NetMode!=NM_Client )
			SetTimer(0,false);
		break;
	case 1:
		PlayAnim('Idle');
		break;
	case 2:
		LoopAnim('Attack',1.6f);
		if( Level.NetMode!=NM_Client )
			SetTimer(0.06,true);
		break;
	case 3:
		PlayAnim('Run');
		break;
	}
	ClientAnimNum = Num;
	bPhysicsAnimUpdate = false;
}
simulated final function name GetCurrentAnim()
{
	local name Anim;
	local float frame,rate;

	GetAnimParams(0, Anim,frame,rate);
	return Anim;
}
simulated function AnimEnd( int Channel )
{
	if( RepAnimationAction!=0 || bPhysicsAnimUpdate )
		return;
	bPhysicsAnimUpdate = true;
	if( Controller!=None )
		Controller.AnimEnd(Channel);
}

function Timer()
{
	local vector X,HL,HN;
	local Actor A,Res;

	if( Controller==None )
		return;
	if( Controller.Enemy!=None )
		X = Normal(Controller.Enemy.Location-Location);
	else X = vector(Rotation);
	X = Normal(X+VRand()*0.04f);

	foreach TraceActors(Class'Actor',Res,HL,HN,Location+X*200.f,Location)
	{
		if( Res!=Self && (Res==Level || Res.bBlockActors || Res.bProjTarget || Res.bWorldGeometry) && ROPawn(Res)==None
			 && ROBulletWhipAttachment(Res)==None && Shepard(Res)==None )
		{
			A = Res;
			log("DOG PAWN FUNCTION TIMER: BREAK");
            break;
		}
	}
	if( A!=None && ROPawn(A)!=None )  //check if none
	{
		log("DOG PAWN FUNCTION TIMER: DOING DAMAGE");
        A.TakeDamage(HitDamage,OwnerPawn,HL,X*1000.f,Class'DamTypeShepard');
	}
	else if( A==None )
		HL = Location+X*8000.f;

	if( Level.NetMode!=NM_StandAlone )
	{
		if( VSize(RepHitLocation-HL)<2.f )
			RepHitLocation+=VRand()*2.f;
		else RepHitLocation = HL;
	}
}

function TakeDamage(int Damage, Pawn InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional int HitIndex)

{      //we dont use rhuman pawn in RO
//	if( ROPawn(InstigatedBy)!=None) // || DamageType==class'DamTypePipeBomb' )
//		return;
    //  check pawn, team, weapon and so on. Check vehicle....

	Super.TakeDamage(Damage,InstigatedBy,HitLocation,Momentum,DamageType,HitIndex);
	//ShepardControllerROBot(Controller).ChangeEnemy(InstigatedBy);
	//ShepardControllerROBot(Controller).GoNextOrders();
    //ShepardControllerROBot(Controller).ChangeEnemy(InstigatedBy);
	//ShepardControllerROBot(Controller).GoNextOrders();
	RORUDogBot(Controller).ChangeEnemy(InstigatedBy);
	RORUDogBot(Controller).GoNextOrders();
    Speech(4);


}


function Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	PlayerReplicationInfo = None;
	if( WeaponOwner!=None )
	{
		if( OwnerPawn!=None && PlayerController(OwnerPawn.Controller)!=None )
			PlayerController(OwnerPawn.Controller).ReceiveLocalizedMessage(Class'ShepardMessage',2);
		WeaponOwner.CurrentSentry = None;
		WeaponOwner.Destroy();
		WeaponOwner = None;
	}
	if( Controller!=None )
		Controller.bIsPlayer = false;
	PlaySound(VoicesList[3],SLOT_Talk,2.5f,,450.f);
	Super.Died(Killer,damageType,HitLocation);
}

simulated event PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	AmbientSound = None;
	GotoState('Dying');
	bReplicateMovement = false;
	bTearOff = true;
	Velocity += TearOffMomentum;
	SetPhysics(PHYS_Falling);
	bPlayedDeath = true;
	PlayAnim('Idle');   // no dying anim yet.
}

final function Speech( byte Num )
{
	local Sound S;

	if( NextVoiceTimer>Level.TimeSeconds )
		return;
	NextVoiceTimer = Level.TimeSeconds+1.f+FRand()*2.f;
	switch( Num )
	{
	case 0: // Wake up
		S = VoicesList[0];
		break;
	case 1: // Can't find player
		S = VoicesList[1+Rand(2)];
		break;
	case 2: // Fight enemy
		S = VoicesList[4+Rand(2)];
		break;
	case 3: // Enemy dead
		S = VoicesList[6];
		break;
	case 4: // Take hit.
		S = VoicesList[7+Rand(4)];
		break;
	case 5: // Shut down
		S = VoicesList[11];
		break;
	case 6: // Sighted player
		S = VoicesList[12];
		break;
	case 7: // Searching player
		S = VoicesList[13+Rand(3)];
		break;
	}
	PlaySound(S,SLOT_Talk,2.5f,,450.f);
}

simulated function HurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation );

State Dying
{
ignores Trigger, Bump, HitWall, HeadVolumeChange, PhysicsVolumeChange, Falling, BreathTimer, TakeDamage, Landed, SetAnimationNum, Timer;

	simulated function EndState()
	{
		//HurtRadius(400,500,Class'DamTypeFrag',100000.f,Location);    F1GrenadeDamType
	   HurtRadius(400,500,Class'F1GrenadeDamType',100000.f,Location);
    }

	function Landed(vector HitNormal);
	function LandThump();
	event AnimEnd(int Channel);
	function LieStill();
	function BaseChange();

	simulated function BeginState()
	{
		local int i;

		LifeSpan = 1.75f;
		SetPhysics(PHYS_Falling);
		SetCollision(false);
		if ( Controller != None )
			Controller.Destroy();
		for (i = 0; i < Attached.length; i++)
			if (Attached[i] != None)
				Attached[i].PawnBaseDied();
	}
Begin:
}

defaultproperties
{
     //hitdamage=7
     hitdamage=34

    // SentryHealth=250
    SentryHealth=6000000

     VoicesList(0)=Sound'RORU_Shepard_snd.npc_dog_bark_01'
     VoicesList(1)=Sound'RORU_Shepard_snd.npc_dog_bark_02'
     VoicesList(2)=Sound'RORU_Shepard_snd.npc_dog_bark_03'
     VoicesList(3)=Sound'RORU_Shepard_snd.npc_dog_injured_01'
     VoicesList(4)=Sound'RORU_Shepard_snd.npc_dog_attackforward_01'
     VoicesList(5)=Sound'RORU_Shepard_snd.npc_dog_attackforward_02'
     VoicesList(6)=Sound'RORU_Shepard_snd.npc_dog_bark_04'
     VoicesList(7)=Sound'RORU_Shepard_snd.npc_dog_injured_01'
     VoicesList(8)=Sound'RORU_Shepard_snd.npc_dog_injured_02'
     VoicesList(9)=Sound'RORU_Shepard_snd.npc_dog_injured_03'
     VoicesList(10)=Sound'RORU_Shepard_snd.npc_dog_injured_04'
     VoicesList(11)=Sound'RORU_Shepard_snd.npc_dog_injured_05'
     VoicesList(12)=Sound'RORU_Shepard_snd.npc_dog_sniff_01'
     VoicesList(13)=Sound'RORU_Shepard_snd.npc_dog_sniff_02'
     VoicesList(14)=Sound'RORU_Shepard_snd.npc_dog_sniff_03'
     VoicesList(15)=Sound'RORU_Shepard_snd.npc_dog_sniff_04'

     FiringSounds(0)=Sound'RORU_Shepard_snd.npc_dog_attackforward_01'
     FiringSounds(1)=Sound'RORU_Shepard_snd.npc_dog_attackforward_02'
     FiringSounds(2)=Sound'RORU_Shepard_snd.npc_dog_attackforward_03'
     FiringSounds(3)=Sound'RORU_Shepard_snd.npc_dog_attackforward_04'
     FiringSounds(4)=Sound'RORU_Shepard_snd.npc_dog_attackforward_05'

     bScriptPostRender=True

     SightRadius=1500.000000

     PeripheralVision=-1.000000

     //GroundSpeed=300.000000
     GroundSpeed=600.000000
     JumpZ=350.000000
     BaseEyeHeight=0.000000
     EyeHeight=0.000000

     //Health=250
      Health=60

//     ControllerClass=Class'Shepard.ShepardController'
   //  ControllerClass=Class'zShepardKFRO.ShepardController'
    // ControllerClass=Class'zShepardKFRO.ShepardControllerROBot'
     ControllerClass=Class'zShepardKFRO.RORUDogBot'
     bPhysicsAnimUpdate=True

     MovementAnims(0)="Run"
     MovementAnims(1)="Run"
     MovementAnims(2)="Run"
     MovementAnims(3)="Run"

     TurnLeftAnim="Run"
     TurnRightAnim="Run"

     SwimAnims(0)="Run"
     SwimAnims(1)="Run"
     SwimAnims(2)="Run"
     SwimAnims(3)="Run"

     CrouchAnims(0)="Run"
     CrouchAnims(1)="Run"
     CrouchAnims(2)="Run"
     CrouchAnims(3)="Run"

     WalkAnims(0)="Run"
     WalkAnims(1)="Run"
     WalkAnims(2)="Run"
     WalkAnims(3)="Run"

     AirAnims(0)="Run"
     AirAnims(1)="Run"
     AirAnims(2)="Run"
     AirAnims(3)="Run"

     TakeoffAnims(0)="Run"
     TakeoffAnims(1)="Run"
     TakeoffAnims(2)="Run"
     TakeoffAnims(3)="Run"

     LandAnims(0)="Run"
     LandAnims(1)="Run"
     LandAnims(2)="Run"
     LandAnims(3)="Run"

     DoubleJumpAnims(0)="Run"
     DoubleJumpAnims(1)="Run"
     DoubleJumpAnims(2)="Run"
     DoubleJumpAnims(3)="Run"

     DodgeAnims(0)="Run"
     DodgeAnims(1)="Run"
     DodgeAnims(2)="Run"
     DodgeAnims(3)="Run"
     AirStillAnim="Run"
     TakeoffStillAnim="Run"
     CrouchTurnRightAnim="Run"
     CrouchTurnLeftAnim="Run"
     IdleCrouchAnim="Idle"
     IdleSwimAnim="Idle"
     IdleWeaponAnim="Idle"
     IdleRestAnim="Idle"
     IdleChatAnim="Idle"

     bStasis=False
     Physics=PHYS_Falling

     Mesh=SkeletalMesh'RORU_Shepard_anm.RORUShepardMesh'
    // Mesh=SkeletalMesh'RORU_Shepard_anm.RORU_ShepardMesh'
    //Mesh=SkeletalMesh'axis_ahz_Pak43_anm.pak43_body'
//     StaticMeshRef="Flare_R.FlareMeshPickup" неверно

//ВЕРНО StaticMesh=StaticMesh'Flare_R.FlareMeshPickup'

     PrePivot=(Z=-5.000000)

     Skins(0)=Texture'RORU_Shepard_tex.ShepardSkin'
     Skins(1)=Texture'RORU_Shepard_tex.ShepardEyeSkin'

     CollisionRadius=20.000000
     CollisionHeight=23.000000
     //CollisionRadius=23.000000
     //CollisionHeight=52.000000
    // bUseCylinderCollision=True
   //  bBlockHitPointTraces=False

     Buoyancy=99.000000
     RotationRate=(Pitch=3072,Roll=2048)

     LightHue=204
     LightBrightness=255.000000
     LightRadius=3.000000
     bActorShadows=True
     bDramaticLighting=True
     //bStasis=False  redundant

     Mass=400.000000
}
