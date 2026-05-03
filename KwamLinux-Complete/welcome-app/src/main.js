// ============================================================
//  KWAMLINUX Welcome App - Electron Entry Point
//  Runs the welcome screen as a native desktop window
// ============================================================

const { app, BrowserWindow, ipcMain, shell } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 860,
        height: 580,
        minWidth: 720,
        minHeight: 480,
        resizable: true,
        center: true,
        title: 'Welcome to Kwamlinux',
        icon: path.join(__dirname, '../assets/icon.png'),
        frame: false,
        transparent: true,
        vibrancy: 'ultra-dark',
        webPreferences: {
            nodeIntegration: false,
            contextIsolation: true,
            preload: path.join(__dirname, 'preload.js'),
        },
        backgroundColor: '#00000000',
    });

    mainWindow.loadFile(path.join(__dirname, 'index.html'));

    // Don't show until ready to avoid flash
    mainWindow.once('ready-to-show', () => {
        mainWindow.show();
    });

    // Open external links in default browser
    mainWindow.webContents.setWindowOpenHandler(({ url }) => {
        shell.openExternal(url);
        return { action: 'deny' };
    });
}

app.whenReady().then(() => {
    createWindow();

    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) createWindow();
    });
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') app.quit();
});

// Handle close from renderer
ipcMain.on('close-window', () => mainWindow.close());
ipcMain.on('minimize-window', () => mainWindow.minimize());
