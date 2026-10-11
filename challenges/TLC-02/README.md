# Stage 2: Information Gathering & Steganography

## Overview
In Stage 2, the goal is to locate a hidden image file as user `levin`, extract its metadata comment using `exiftool`, and decode the Base64 payload to obtain clues for Stage 3[cite: 1, 3].

---

## Step-by-step Walkthrough

### Step 1: Navigating to the Target Directory
After logging in as user `levin`, navigate to `/usr/src/images` where `family.png` is stored:

```bash
cd /usr/src/images
ls
```

### Step 2: Checking Image Metadata
Next, I ran `exiftool` on `family.png` to check for any hidden information in the image details.

```bash

exiftool family.png
```

![Stage 2 Metadata Output](stage2-exiftool.png)


### Step 3: Decoding the Base64 Clue

To read the hidden message, I took the comment string and decoded it using the base64 command

```bash

echo "RmluZCBjbHVlcyB3aXRoIGluIHRoZXNlIGRpc2VjdG9yaWVzICIvdmFyL2xvY2FsI3IgI9yIC91c3Iv.c2hcmUiCg==" | base64 -d

```