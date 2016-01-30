class InventoryMutator extends Mutator;

//This is basically a common inventory replacement mutator, to serve as an example.

simulated function NeginPlay(){


    foreach AllActors(class'>RoleToModify<', RoleToModifyName, ){
          Log("Found a matching RInfo!");
         RoleInfo.default.PrimaryWeapons="OurCustomInventoryClass";
   //Above: we are replacing the PrimaryWeapons straight in the role itself
   //We will force the mutator to only do this on a specific RI, matching our "limit"
   //We will check the Unit AND role type itself.
   //we will be replacing Satchel, so we will just tell the mutator to look for "CombatEngineer" or "Pioneer"
   //other variations should also be added to add support in case of inconsistency.
   //(for example "Combat Engineer", "Comabt-Engineer" and etc.


    Super.BeginPlay();
}

//to be continued......
