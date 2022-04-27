# JWST:

This repository contains all the files for the application.

## Mobile Application:

### lib: Contians Flutter code.
### Android: Contains Android files.
### iOS: Contains iOS application files.

## Python Script:

Python script is available in `python` directory.

### How to use?

From project root, use following commands.

```
cd python
python images.py
```

### Note: You require python 3.7 or above for this. Also, you will have to install all the dependency yourself.

## Cloud Functions:

All the cloud functions are written in `Typescript` and are available in `functions/src/index.ts` file. The necessary files are availble in `functions/src` folder.

### How to use?

To deploy the cloud function, use following commands. (From project root).

```
cd functions
firebase login
firebase deploy
```

### Note: you will have to install firebase tools using link: https://firebase.google.com/docs/cli#windows-npm




