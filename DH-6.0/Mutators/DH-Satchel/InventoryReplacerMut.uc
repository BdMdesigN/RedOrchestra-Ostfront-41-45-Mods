class InventoryMutator extends Mutator;

//This is basically a common inventory replacement mutator, to serve as an example.

simulated function NeginPlay(){
{
    
    foreach AllActors(class'>RoleToModify<', RoleToModifyName, ){
    {
          Log("Found a matching RInfo!");
         RoleInfo.default.PrimaryWeapons="OurCustomInventoryClass";
    }
   //Above: we are replacing the PrimaryWeapons straight in the role itself
   //We will force the mutator to only do this on a specific RI, matching our "limit"
   //We will check the Unit AND role type itself.
   //we will be replacing Satchel, so we will just tell the mutator to look for "CombatEngineer" or "Pioneer"
   //other variations should also be added to add support in case of inconsistency.
   //(for example "Combat Engineer", "Comabt-Engineer" and etc.
   
   ForEach AllActors (OUR ROLE (see above)
   if(our role) matches (the role we are lookin for)
>>>Perform inventory replacement:

if (RInfo.name ==  'ROSUGunnerM35RKKA0')
         {
          Log("Found a matchingrole !");
         "HERE SET THE VARIABLE (see above)"
        }
    else if (RInfo.name == "SomeOtherRole")
       {
           this time we do something else.
       }
    Above example: if role is "allied" then replace the primary weapon with a custom allied weapon.
    If not, and the role is a axis, then we do something else (replace primary weapon with axis one)
    

    Super.BeginPlay();  //continue with the rest of the Beginplay function: The keyword allows us to avoid having to override the whole function.
}

//And here is an example of some role specific stuff:
    RoleType=ROLE_ASSAULT
     MyName="Assault Trooper"
     AltName="Stoßtruppe"
     Article="an "
     PluralName="Assault Troops"
     
//As you can see, there is plenty of stuff to look for and check: Type of Role, name of role, alternate (native) name.....
//So if you have more than one Units type on a single map, you can act depending on this too.
//Example could be: a Volksturm Rifleman, an SS Rifleman and a Heer Standard Rifleman.
//For the Volksturm rifleman we may want to remove the grenades and give a custom rifle with just one spare clip of ammunition.
//For the SS Rifleman we may want to replace the bolt action rifle with a semi-auto one and give him a secondary weapon (pistol)
//While for the Heer Standard rifleman we may want to replace the "two" grenades with a single one.
//Now, add some randomness and you can achieve pretty neat results.
//Having small chance to spawn without rifle or without ammo if you are playing as a soviet soldier in Stalingrad.
//Or having a decent chance to receive an STG 44 instead of MP 40.

//Of course bear in mind that these random swapps will happen at the beginning of the round and will stay until the map changes.
//meaning that if specific role gets an STG instead of MP 40 they will be able to spawn with it during the whole duration of the game.

//In the next example, we will see a different, more "dynamic" system, that can allow one to modify stuff on the fly,
//and give the player a chance to spawn with different weapon EACH and EVERY time he spawns.

//to be continued......
