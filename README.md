# JWST:

This repository contains all the files for the application.

## Mobile Application:

#### lib: Contians Flutter code.
#### Android: Contains Android files.
#### iOS: Contains iOS application files.

## Python Script:

Python script is available in `python` directory.

### How to use?

From project root, use following commands.

```
cd python
python images.py
```

#### Note: You require python 3.7 or above for this. Also, you will have to install all the dependency yourself.

## Cloud Functions:

All the cloud functions are written in `Typescript` and are available in `functions/src/index.ts` file. The necessary files are availble in `functions/src` folder.

### How to use?

To deploy the cloud function, use following commands. (From project root).

```
cd functions
firebase login
firebase deploy
```

#### Note: you will have to install firebase tools using link: https://firebase.google.com/docs/cli#windows-npm


## Tutorials/Beginners Guide:

### Flutter Application:

To start Flutter application, you will first have to install Flutter tools from https://docs.flutter.dev/get-started/install.


Then you can use Android studio or VSCode to run application.

### Handle Firestore:

The firestore is accessible from Google firebase console here https://console.firebase.google.com/.

#### Access datastore:

<img width="1726" alt="image" src="https://user-images.githubusercontent.com/16891971/165429321-a34a23f7-ad59-43df-a8c4-4d74b8d5ae6a.png">

#### Access Cloud Functions:

<img width="1692" alt="image" src="https://user-images.githubusercontent.com/16891971/165429413-6a82fc48-a4f5-45ab-9b4b-5b286d9a794e.png">

#### Looka at Function Logs:

https://user-images.githubusercontent.com/16891971/165429546-32601755-7d72-4e04-9a4e-ad0a26c2cdd3.mov


#### Adding an image manually

https://user-images.githubusercontent.com/16891971/165429841-5f6664c6-0979-4691-badd-2a8229dbb096.mov







