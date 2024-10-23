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

In this post, I will be going over the basics of game writing game cheats. We will be messing with the game [Pwn Adventure 3](https://www.pwnadventure.com/). This game was made to be a part of a CTF, so this game was made to be hacked. This makes it the perfect target to start learning this stuff!

We will go over the following:
- Memory
- Assembly Basics
- Hooking
- Turning this into C++ code

Let's jump into it!

## How can games be hacked?

Not every game is the same. You need to approach almost every game differently. This is because you typically want to make your mods, in a similar way to how the game was coded. For example, with unity games which are scripted in C#, you will typically make your mods in C#, games written in C++ you will typically make your 'mods' in C++. 

## Native Game Hacking

This is the 'method' of game hacking that we will be going over. It's the most generalized technique and can essentially be applied to any game. It might not be the most efficient way to do things in every scenario, but it's a great method to build off of if you decide to learn other methods.

When natively game hacking, you are direclty modifying the games memory and code. [Cheat Engine](https://www.cheatengine.org/) is a great way to start messing around with all of this without having to write any code.

