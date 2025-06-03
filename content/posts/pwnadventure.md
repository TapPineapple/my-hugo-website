+++
title = "Pwn Adventure  3 Noclip Hack"
description = ""
type = ["posts","post"]
tags = [
]
date = "2024-10-23"
categories = [
    "c++",
    "game hacking",
    "pwn-adventure"
]
+++

## Overview

In this post, I will be going over the basics of writing game cheats. We will be messing with the game [Pwn Adventure 3](https://www.pwnadventure.com/). This game was made to be a part of a CTF, so this game was made to be hacked. This makes it the perfect target to start learning this stuff!

The project that is referenced in this post is on my GitHub [here](https://github.com/TapPineapple/pwn-adventure-fun).

We will go over the following:
- Hooking
- Noclip Math
- Throwing this all together in Code

Let's jump into it!

## What's our goal?
Our goal in this project will be to create a functioning noclip hack for the game Pwn Adventure 3. We will do this by taking the player's position cordinates and overwriting them with new values based on the logic in our noclip code. 

The game's physics engine will also be fighting our noclip hack, this means that we need to also overwrite the player's movement velocity variables. If we don't do this our character will teleport around when the noclip hack is in effect. 

This will hopefully all make more sense when we get to actually coding up the program.


## Finding the players position & velocity variables
There are likely many different ways to to find these values but I will be going over the method that I used.

I used floating point scans in cheat engine to find the value for the players position on the vertical axis. Once I found that, it was right after the X,Y values for the player's position in memory. Next I opened up the memory view and looked around for values that could resemble the players velocity address.

Once I found these two memory locations, I attached the cheat engine debugger and clicked "find out what accesses this address". My goal in doing this is to find a good function to use that references these variables in the registers. This is useful to know because we need to be able to find these addresses somehow in our cheat. We will be able to copy the address out of the registers in the game's code into a variable in our noclip code.

Hopefully this will make more sense when we look at it in the actual source code.

## Digging into the source code 

Now that we kind know what's going on behind the scenes, lets get into the actual source code.

This is an internal cheat which means we are writing this in the context of a windows dynamic link library (dll). Since we are writing a DLL we will need to inject this into the games process using some sort of external dll injector. [Master131's injector](https://github.com/master131/ExtremeInjector) works well for this.

First we will go over the first bit of the code in the 'main' function
```cpp
uintptr_t gameLogicBA = (uintptr_t)GetModuleHandle(L"GameLogic.dll");
uintptr_t pwnAdventure3BA = (uintptr_t)GetModuleHandle(L"PwnAdventure3-Win32-Shipping.exe");

std::cout << "GameLogic.dll base address: 0x" << std::hex << gameLogicBA << std::endl;
std::cout << "PwnAdventure3-Win32-Shipping.exe base address: 0x" << std::hex << pwnAdventure3BA << std::endl;
```
In the above code snippit, we are obtaining the beginning addresses of each 'module'. This is a needed step because these address are randomized each time the program restarts. This is a product of a security feature in the OS called [ASLR](https://en.wikipedia.org/wiki/Address_space_layout_randomization).

```cpp
pHookManager = new Utility::HookManager();

uintptr_t hPlayerPosition = pwnAdventure3BA + 0xC0087; //the functions we will be hooking
uintptr_t hPlayerVelocity = pwnAdventure3BA + 0x8926A4;
pHookManager->HookFunctionExt(hPlayerPosition, (uintptr_t)getPlayerPosition, 7, false); // hook player position
pHookManager->HookFunctionExt(hPlayerVelocity, (uintptr_t)getPlayerVelocity, 6, false); // hook player velocity
```
The code above is where we initialize the hooks at the code locations found earlier in cheat engine. We use these hooks to 'rip out' the content of specific registers and store their values in some global variables in the source code of our DLL.

The hooking library that I'm using is [mambda's hooking library](https://bitbucket.org/mambda/hook_lib/src/master/) which I found somewhere on guidedhacking a while back.
```cpp
int getPlayerPosition(Utility::x86Registers* pRegs)
{
    uintptr_t playerPosition = pRegs->ecx + 0x90;
    pPlayerPosition = (vec3*)playerPosition;
    uintptr_t playerYaw = pRegs->ecx + 0xFC;
    pPlayerYaw = (float*)playerYaw;

	// Return the original function
	return Utility::HookManager::EXECUTE_TARGET_FUNCTION;
}

int getPlayerVelocity(Utility::x86Registers* pRegs)
{
    uintptr_t playerVelocity = pRegs->ecx + 0x7C;
	pPlayerVelocity = (vec3*)playerVelocity;

	// Return the original function
	return Utility::HookManager::EXECUTE_TARGET_FUNCTION;
}
```
The code above is the where the hooks are directed to, you can see that we manage to save the players position in the `pPlayerPosition` variable which was stored at `ecx + 0x90`. The same goes for `pPlayerVelocity` which was stored at `ecx + 0x7C`. It's also worth noting that the player yaw was stored in a similar location as the player's position. This is good to know because we will use it for the noclip code. 

```cpp
while (!GetAsyncKeyState(VK_ESCAPE))
{
    //toggles when you press the 'F' key
    if (GetAsyncKeyState(0x46) & 1)
	{
		bFlyHack = !bFlyHack;
	}
    if (bFlyHack && pPlayerPosition && pPlayerVelocity && pPlayerYaw)
    {
        
        pPlayerVelocity->x = 0.0f;
        pPlayerVelocity->y = 0.0f;
        pPlayerVelocity->z = 0.0f;
        
        float speed = 175.0f;
        float radYaw = (*pPlayerYaw * (PI / 180 ));
        if (GetAsyncKeyState(0x57)) //w
        {
            pPlayerPosition->x = pPlayerPosition->x + cos(radYaw) * speed;
            pPlayerPosition->y = pPlayerPosition->y + sin(radYaw) * speed;
        }
        if (GetAsyncKeyState(0x53)) //s
        {

            pPlayerPosition->x = pPlayerPosition->x - cos(radYaw) * speed;
            pPlayerPosition->y = pPlayerPosition->y - sin(radYaw) * speed;
        }
        if (GetAsyncKeyState(0x51)) //q
        {
            pPlayerPosition->z -= speed;
        }
        if (GetAsyncKeyState(0x45)) //e
        {
            pPlayerPosition->z += speed;
        }    
    }
    Sleep(25);
}
```

The above code contains the actual logic for the noclip. We use the winapi function `GetAsyncKeyState()` to determine what keys are currently being pressed. 

All we are doing in this code is taking the current players position and doing some vector math to determine what we should change the position to. We only take into account the current Yaw of the player character (which way we are looking). This way you can hold `W` and you will move in the direction you are looking.

Here's a fun picture of it in action!
![pwnfly](/img/pwnfly.png)

## Summary

Welp that just about wraps up this little project. I made this project for a different presentation that was intended to be an Intro to Game Hacking, but I figured that this code is still fun enough to do a little writeup about it. Hopefully someone found this interesting, if you have any advice or anything else you can contact me on discord @ `tappineapple`