Welcome to my RP-1 (Realistic Progression One) playthrough for the amazing game of Kerbal Space Program and the Realism Overhaul suite of mods.

I started playing KSP just before version 1.0.0 was released and I have to admit that I haven't played stock KSP a lot. That was because I have discovered the Realism Overhaul. Just the thought that you could recreate the Space program from the earliest rockets to actually plan manned missions to Mars and beyond was mind blowing. Versions 1.1.3 and 1.2.2 were the two I spend most the my time and 1.8.1 nowadays.

This repo is my kind of contribution to the community of all the people working to create, maintain, improving and eventually playing this overhaul of stock KSP to its Realism glory.

**My style of play**

From early on I stared playing with KOS (Kerbal Operating System) mod that allows you to write scripts to guide your rockets instead of manual control like a barbarian. Thought my playthroughs I created a lot of code and a system to manage them. Unfortunately most of my scripts didn't survive the transition from RP-0 to RP-1 and after some years of downtime I am back to the game, updating my library for the newer version of RP-1 for 1.8.1.

While a lot of players are using Mechjeb for their orbital business, I prefer a more pragmatic approach instead of pure magic that Mechjeb is. Everything is controlled from a script with some minor exceptions, like early SRB shots of The Moon&trade; and manned space stations actions.

**KISS**

Generally I exercise the [KISS](https://en.wikipedia.org/wiki/KISS_principle) principle on my rockets and scripts. Simpler rockets have fewer parts (increased performance), are easier to maintain and cost less.

**How Scripts work**

All KOS scripts are stored on /Ship/Script folder, four main folders (boot, lib, missions, sub) keep scripts tidy.

![G1](https://raw.githubusercontent.com/iezekiel/RP-1/main/images/G1.png?raw=true)

On every rocket the root part is configured to use the RP1.ks file from boot folder. RP1.ks initialises the terminal window and loads the mission file, the mission file is set on the Change Name Tag (CORE:TAG) again on the root part. Every mission is stored on the missions folder.

	LOCAL missionFile IS CORE:TAG + ".mission.ks".
	RUNONCEPATH("0:/missions/"+missionFile).

I keep different mission profiles for usage on multiple rockets instead of using the Mission Name to locate the appropriate mission file.

	//Variables
	LOCAL targetAzimuth TO 90.
	LOCAL targetApoapsis TO 250000.
	LOCAL flameOutWait IS 0.1.
	LOCAL cdIgnite TO 3.
	LOCAL pitchStart IS 70.
	LOCAL pitchMultiplier IS 1.

	// Automatically start ascent
	RUNPATH("0:/lib/LaunchProgradeHB.ks",targetAzimuth, targetApoapsis,flameOutWait,cdIgnite,pitchStart,pitchMultiplier).

A typical mission file contains the variables for the mission and the scripts that need to be used. For example the First Orbital Rocket sets the orbit and rocket parameters and executes the LaunchProgradeHB.ks script on lib folder. Folder lib contains the logic for each action you want to execute and helper functions. Sub folder contains sub-missions that are part of a mission, for example the retro routine of a manned orbital spacecraft.

**Hey I recognise that code block**

A lot of the code is a mesh of other scripts found online, snippets from forums and code written by me. While I am trying to give credit to the original authors in some cases that's not possible. If you think that you should be credited please contact me.
