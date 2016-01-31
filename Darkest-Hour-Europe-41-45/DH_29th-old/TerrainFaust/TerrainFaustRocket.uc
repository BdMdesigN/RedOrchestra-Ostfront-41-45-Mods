class TerrainFaustRocket extends PanzerFaustRocket;

var int CraterRadius, CraterDepth;

simulated singular function HitWall(vector HitNormal, actor Wall)
{
	//Woohoo! Destructable terrain!
	if (TerrainInfo(Wall) != None)
	{
		TerrainInfo(Wall).PokeTerrain(Location, CraterRadius, CraterDepth);
		log("Terrain Created [Radius: " $ CraterRadius $ "] [Depth: " $ CraterDepth $ "]");
		ExploWallOut = 0;

	}

	//Super.HitWall(HitNormal, Wall);
	Explode(Location + ExploWallOut * HitNormal, HitNormal);
	Destroy();
}

defaultproperties
{
	CraterRadius=128
	CraterDepth=128
}
