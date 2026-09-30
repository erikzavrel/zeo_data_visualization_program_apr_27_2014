// Zeo Data Visualization Program
// EA Zavrel

// Notes:
// Program plots / displays sleep stage and EEG data, reconstructing hyponogram for visualization of data logged to SD card.
// Program is intended to be used to gauge the accuracy of Zeo compared to PSG.

// Most of program written Dec 2012.
// Feb 2013: Addressed several issues including alignment / synchronizing of data by finding least common time stamp
// and ability to display data from both single night format files (stamped with full name and not date) and multiple night format files (stamped with month and date).
// Problem why single night files were not able to be loaded before was because after entering that file names did not have month and date stamp, program state was set to
// to prompt user to select desired resolution, skipping over the loading of files = easy fix.
// Added feature to toggle displayed data so rather than displaying all data on screen, can choose which data to display for easier viewing.
// June 7 2013: Made cosmetic changes: font style, size, etc.
// June 23 2013: Changed i.e. to e.g. in user prompts, added reminder that files to be accessed must be placed in data directory of program
// June 24 2013: Changed variable names (day_of_month to date_ etc)
// June 27 2013: Put in check / safeguard to make sure requested file exists before trying to load it
// June 29 2013: Added feature to display on screen names of files being displayed
// July 1 2013: Added "return to main menu" icon so don't have to exit out of program and re-run to view another dataset
// Must reset ALL program flags (collectively, program flags constitute status register)
// Changed name of screenshot .jpeg file to be more descriptive

// Jan 21 2014: Changed order of program flags to be logical: 0, 1, 2. Minor change.

// Data files (eeg and hypnogram) must be placed within the data directory of the processing sketch in order to be accessed

// May decide to add annotation ability for headband impedance / signal quality index if these are logged from Zeo
