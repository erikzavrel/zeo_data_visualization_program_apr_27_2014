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

// **************************************************************************************************************************************************************** 

String[] eeg_data_file_array; // declare array - read entire eeg data file into array for subsequent processing
String[] hypnogram_data_file_array; // declare array - read entire sleep stage data file into array for subsequent processing

int eeg_data_file_array_size; // size of eeg data file array (including header)
int hypnogram_data_file_array_size; // size of sleep stage data file array (including header)

final byte file_header_offset = 4; // header offset (file title, blank line, column description, blank line)

int eeg_data_file_array_header_removed_size; // size of eeg data file array minus offset (actual data items)
int hypnogram_data_file_array_header_removed_size; // size of sleep stage data file array minus offset (actual data items)

String[] eeg_data_file_array_header_removed; // declare array - subset of eeg data file array with header removed (only data)
String[] hypnogram_data_file_array_header_removed; // declare array - subset of sleep stage data file array with header removed (only data)

String single_line_from_eeg_data_file_array; // for parsing eeg data file array line by line
String single_line_from_hypnogram_data_file_array; // for parsing sleep stage data file array line by line

String[] parsed_items; // declare array for parsed values (comma delimited)

int eeg_data_file_array_aligned_size; // size of eeg data array aligned with least common time stamp
int hypnogram_file_data_array_aligned_size; // size of sleep stage data array aligned with least common time stamp
int maximum_guaranteed_eeg_data_array_pointer; // 30*(n-1), n = number of sleep stages in aligned hypnogram data as n will not have a full 30 eeg points to go along with it, between 0 and 29 eeg points for last sleep stage determination
 
String[] eeg_data_file_array_aligned; // declare array - subset of eeg data, aligned with least common time stamp
String[] hypnogram_data_file_array_aligned; // declare array - subset of sleep stage data, aligned with least common time stamp

int array_pointer = 0; // for indexing arrays
int eeg_data_array_pointer = 0; // for indexing arrays
int hypnogram_data_array_pointer = 0; // for indexing arrays

boolean found_least_common_time_stamp_program_flag = false; // set when least common time stamp is found

int eeg_data_year_value;
int eeg_data_month_value;
int eeg_data_date_value;
int eeg_data_hour_value;
int eeg_data_minute_value;
int eeg_data_second_value; // eeg time stamp data

int brain_wave_delta_absolute;
int brain_wave_theta_absolute;
int brain_wave_alpha_absolute;
int brain_wave_beta_13_to_18_absolute;
int brain_wave_beta_18_to_21_absolute;
int brain_wave_beta_11_to_14_sleep_spindles_absolute;
int brain_wave_gamma_absolute; // eeg data absolute values

int eeg_activity_total; // used for calculating relative values

float brain_wave_delta_relative;
float brain_wave_theta_relative;
float brain_wave_alpha_relative;
float brain_wave_beta_13_to_18_relative;
float brain_wave_beta_18_to_21_relative;
float brain_wave_beta_11_to_14_sleep_spindles_relative;
float brain_wave_gamma_relative; // eeg data relative values

int[] eeg_data_unaligned_year_value_array; // declare array 
int[] eeg_data_unaligned_month_value_array; // declare array 
int[] eeg_data_unaligned_date_value_array; // declare array 
int[] eeg_data_unaligned_hour_value_array; // declare array 
int[] eeg_data_unaligned_minute_value_array; // declare array 
int[] eeg_data_unaligned_second_value_array; // declare array 

int[] eeg_data_aligned_year_value_array; // declare array
int[] eeg_data_aligned_month_value_array; // declare array
int[] eeg_data_aligned_date_value_array; // declare array
int[] eeg_data_aligned_hour_value_array; // declare array
int[] eeg_data_aligned_minute_value_array; // declare array
int[] eeg_data_aligned_second_value_array; // declare array

int[] brain_wave_delta_absolute_array; // declare array 
int[] brain_wave_theta_absolute_array; // declare array 
int[] brain_wave_alpha_absolute_array; // declare array 
int[] brain_wave_beta_13_to_18_absolute_array; // declare array 
int[] brain_wave_beta_18_to_21_absolute_array; // declare array 
int[] brain_wave_beta_11_to_14_sleep_spindles_absolute_array; // declare array 
int[] brain_wave_gamma_absolute_array; // declare array 

int[] eeg_activity_total_array; // declare array 

float[] brain_wave_delta_relative_array; // declare array 
float[] brain_wave_theta_relative_array; // declare array 
float[] brain_wave_alpha_relative_array; // declare array 
float[] brain_wave_beta_13_to_18_relative_array; // declare array 
float[] brain_wave_beta_18_to_21_relative_array; // declare array 
float[] brain_wave_beta_11_to_14_sleep_spindles_relative_array; // declare array 
float[] brain_wave_gamma_relative_array; // declare array 

int hypnogram_year_value;
int hypnogram_month_value;
int hypnogram_date_value;
int hypnogram_hour_value;
int hypnogram_minute_value;
int hypnogram_second_value; // hypnogram time stamp data

int zeo_sleep_stage; // zeo sleep stage number
int sleep_stage_for_hypnogram; // 5's complement of sleep stage for proper plotting
String sleep_stage_description; // 3 letter abbreviation of sleep stage

int[] hypnogram_unaligned_year_value_array; // declare array 
int[] hypnogram_unaligned_month_value_array; // declare array 
int[] hypnogram_unaligned_date_value_array; // declare array 
int[] hypnogram_unaligned_hour_value_array; // declare array 
int[] hypnogram_unaligned_minute_value_array; // declare array 
int[] hypnogram_unaligned_second_value_array; // declare array 

int[] hypnogram_aligned_year_value_array; // declare array
int[] hypnogram_aligned_month_value_array; // declare array
int[] hypnogram_aligned_date_value_array; // declare array
int[] hypnogram_aligned_hour_value_array; // declare array
int[] hypnogram_aligned_minute_value_array; // declare array
int[] hypnogram_aligned_second_value_array; // declare array

int[] zeo_sleep_stage_array; // declare array 
int[] sleep_stage_for_hypnogram_array; // declare array - zeo sleep stage 5's complement
String[] sleep_stage_description_array; // declare array 

float eeg_array_max_value = 0; // max of an array, for setting ceiling of display of data
float eeg_array_global_max_value = 0; // overall max of array, for setting ceiling of display of data
 
float brain_wave_delta_relative_pixel_location_raw; // mapped eeg value for display of data
float brain_wave_theta_relative_pixel_location_raw; // mapped eeg value for display of data
float brain_wave_alpha_relative_pixel_location_raw; // mapped eeg value for display of data
float brain_wave_beta_13_to_18_relative_pixel_location_raw; // mapped eeg value for display of data
float brain_wave_beta_18_to_21_relative_pixel_location_raw; // mapped eeg value for display of data
float brain_wave_beta_11_to_14_sleep_spindles_relative_pixel_location_raw; // mapped eeg value for display of data
float brain_wave_gamma_relative_pixel_location_raw; // mapped eeg value for display of data

int brain_wave_delta_relative_pixel_location; // mapped eeg value for display of data, rounded to nearest integer (must be integer value, as sometimes float pixel values will not work)
int brain_wave_theta_relative_pixel_location; // mapped eeg value for display of data, rounded to nearest integer (must be integer value, as sometimes float pixel values will not work)
int brain_wave_alpha_relative_pixel_location; // mapped eeg value for display of data, rounded to nearest integer (must be integer value, as sometimes float pixel values will not work)
int brain_wave_beta_13_to_18_relative_pixel_location; // mapped eeg value for display of data, rounded to nearest integer (must be integer value, as sometimes float pixel values will not work)
int brain_wave_beta_18_to_21_relative_pixel_location; // mapped eeg value for display of data, rounded to nearest integer (must be integer value, as sometimes float pixel values will not work)
int brain_wave_beta_11_to_14_sleep_spindles_relative_pixel_location; // mapped eeg value for display of data, rounded to nearest integer (must be integer value, as sometimes float pixel values will not work)
int brain_wave_gamma_relative_pixel_location; // mapped eeg value for display of data, rounded to nearest integer (must be integer value, as sometimes float pixel values will not work)

float time_pixel_location_eeg_raw; // mapped time value for display of data
int time_pixel_location_eeg; // mapped time value for display of data, rounded to nearest integer

int brain_wave_delta_relative_pixel_location_old; // starting point for line segment for display of data
int brain_wave_theta_relative_pixel_location_old; // starting point for line segment for display of data
int brain_wave_alpha_relative_pixel_location_old; // starting point for line segment for display of data
int brain_wave_beta_13_to_18_relative_pixel_location_old; // starting point for line segment for display of data
int brain_wave_beta_18_to_21_relative_pixel_location_old; // starting point for line segment for display of data
int brain_wave_beta_11_to_14_sleep_spindles_relative_pixel_location_old; // starting point for line segment for display of data
int brain_wave_gamma_relative_pixel_location_old; // starting point for line segment for display of data

int time_pixel_location_eeg_old; // previous mapped time value for line segment for display of data

float hypnogram_pixel_location_raw; // mapped sleep stage data for hypnogram display
int hypnogram_pixel_location; // mapped sleep stage data for hypnogram display, rounded to nearest integer
int hypnogram_pixel_location_old; // starting point for line segment for display of hypnogram

float time_pixel_location_hypnogram_raw; // mapped time value for display of data
int time_pixel_location_hypnogram; // mapped time value for display of data, rounded to nearest integer
int time_pixel_location_hypnogram_old; // previous mapped time value for line segment for display of data

final int user_input_prompts_x_offset = 50; // for displaying user prompts
final int user_input_prompts_y_offset = 50; // for displaying user prompts

int display_key_x = 7 * screen.width / 8; // set horizontal position of legend
int display_key_y = 1 * screen.height / 10; // set vertical position of legend
int display_key_y_offset = 30; // vertical spacing
int display_key_x_offset = 6; // horizontal spacing
int display_key_x_offset_multiplier;

int legend_toggle_icon_x = 99 * screen.width / 100; // set where toggle icons appear, far right of screen
int legend_toggle_icon_width = 16; // display data icon 16 pixels wide
int legend_toggle_icon_height = 16; // display data icon 16 pixels high

boolean icon_eeg_display_toggle_state_delta = true; // intitialize display legend state to TRUE
boolean icon_eeg_display_toggle_state_theta = true; // intitialize display legend state to TRUE
boolean icon_eeg_display_toggle_state_alpha = true; // intitialize display legend state to TRUE
boolean icon_eeg_display_toggle_state_beta_13_to_18 = true; // intitialize display legend state to TRUE
boolean icon_eeg_display_toggle_state_beta_18_to_21 = true; // intitialize display legend state to TRUE
boolean icon_eeg_display_toggle_state_beta_sleep_spindles = true; // intitialize display legend state to TRUE
boolean icon_eeg_display_toggle_state_gamma = true; // intitialize display legend state to TRUE

final int gui_icon_x_start = screen.width - 150;
final int gui_icon_x_end = screen.width;
final int gui_icon_y_start = screen.height - 50;
final int gui_icon_y_end = screen.height; // make each icon a square 50 x 50 pixels

int eeg_data_display_vertical_start = 1 * screen.height / 20; // define dimensions of display (vertical extent of eeg data)
int eeg_data_display_vertical_end = 7 * screen.height / 10; // define dimensions of display (vertical extent of eeg data)

int data_display_horizontal_start = 1 * screen.width / 20; // define dimensions of display (horizontal extent of eeg data)
int data_display_horizontal_end = 17 * screen.width / 20; // define dimensions of display (horizontal extent of eeg data)

int hypnogram_display_vertical_start = 3 * screen.height / 4; // define dimensions of display (vertical extent of sleep stage data)
int hypnogram_display_vertical_end = 9 * screen.height / 10; // define dimensions of display (vertical extent of sleep stage data)
int hypnogram_key_y_offset = (hypnogram_display_vertical_end - hypnogram_display_vertical_start) / 4; // vertical spacing for sleep stages: UNK, AWK, REM, L, D

int relative_power_scale_value; // for axis labeling of % power (relative eeg values)
int relative_power_scale_counter; // for axis labeling of % power (relative eeg values)
float relative_power_scale_pixel_location_raw; // for axis labeling of % power (relative eeg values)
int relative_power_scale_pixel_location; // for axis labeling of % power (relative eeg values)

float upper_limit_of_eeg_scale_raw; // for axis labeling of % power (relative eeg values)
int upper_limit_of_eeg_scale; // for axis labeling of % power (relative eeg values)

int seconds_to_display; // display current time on screen
int minutes_to_display; // display current time on screen
int hours_to_display; // display current time on screen
  
int days_to_display; // display current date on screen
int months_to_display; // display current date on screen
int years_to_display; // display current date on screen

String month_name; // 3 letter abbreviation of month rather than numerical representation for display screen

int file_name_month; // if file to load is stamped with month and date, month of file
boolean user_entering_month_of_file_name_digit_1_program_flag = false; // set after 1st digit is entered of MM month

int file_name_date; // if file to load is stamped with month and date, date of file
boolean user_entering_date_of_file_name_digit_1_program_flag = false; // set after 1st digit is entered of DD date

final byte ascii_offset = 48; // to convert to numerical value, must remove ASCII offset, i.e. ASCII representation of 1 is 1 + 48 = 49

byte program_state = 0; // keep track of program execution, initialize to 0

final byte load_logo_upon_startup_program_state = 0;
final byte pause_to_display_logo_upon_startup_program_state = 1;
final byte prompt_user_to_continue_or_exit_program_state = 2;
final byte prompt_user_for_file_naming_convention_program_state = 3;
final byte prompt_user_for_month_of_file_name_program_state = 4;
final byte confirm_month_of_file_name_program_state = 5;
final byte prompt_user_for_date_of_file_name_program_state = 6;
final byte confirm_date_of_file_name_program_state = 7;
final byte load_data_from_files_program_state = 8;
final byte prompt_user_for_desired_data_resolution_program_state = 9; // how many minutes of data to display on screen
final byte viewing_data_program_state = 10; // after all user input has been had and files have been loaded

char EEGDataFileNameArray[] = {'M', 'M', 'D', 'D', '_', 'E', 'E', 'G', '.', 'C', 'S', 'V'}; // MMDD_EEG.CSV
char HypnogramFileNameArray[] = {'M', 'M', 'D', 'D', '_', 'H', 'Y', 'P', '.', 'C', 'S', 'V'}; // MMDD_HYP.CSV 

final byte month_tens_place_file_name_element_number = 0; // will overwrite 0th element in array = 1st character for file names: MMDD_XXX.CSV
final byte month_ones_place_file_name_element_number = 1; // will overwrite 1st element in array = 2nd character for file names: MMDD_XXX.CSV
final byte date_tens_place_file_name_element_number = 2; // will overwrite 2nd element in array = 3rd character for file names: MMDD_XXX.CSV
final byte date_ones_place_file_name_element_number = 3; // will overwrite 3rd element in array = 4th character for file names: MMDD_XXX.CSV

String eeg_file_name; // eeg data file to load
String hypnogram_file_name; // sleep stage data file to load

byte minutes_of_data_to_display; // how many minutes of data to display on screen
int number_of_eeg_data_points_to_display; // how many seconds of data to display on screen
int number_of_sleep_stages_to_display; // number of sleep stages to display on screen
final byte number_seconds_in_a_minute = 60; // for conversion from min to sec

int eeg_data_array_pointer_start = 0; // for displaying of data - from
int eeg_data_array_pointer_end = 0; // for displaying of data - to

int hypnogram_data_array_pointer_start = 0; // for displaying of data - from
int hypnogram_data_array_pointer_end = 0; // for displaying of data - to

DateFormat fnameFormat = new SimpleDateFormat("yyyy_MM_dd_HH_mm_ss"); // file naming format for screenshots
String fileName; // for screenshots

PFont fontA; 
PFont fontB; 

PImage zeo_logo;

int delay_duration = 0; // how long what is rendered to screen gets displayed for

// *****************************************************************************************************************************************************************************************

void setup () {
  
  size(screen.width, screen.height); // make window the same size as screen size - optimizes, makes window as large as possible, use present not run to fill screen
  frameRate(60); // set frame rate high for faster refresh rate - make graphics smoother, PC screen refresh rate is 60 Hz
  background(0); // black background
 
  fontA = loadFont("ArialRoundedMTBold-48.vlw"); // load font - do not load in draw function as will slow program exection
  fontB = loadFont("Calibri-Bold-48.vlw"); // load font - do not load in draw function as will slow program exection
 
  zeo_logo = loadImage("zeo_logo.jpg"); // load logo - do not load in draw function as will slow program exection

} // end of setup

// *****************************************************************************************************************************************************************************************

void draw() {
  
  if (program_state != load_logo_upon_startup_program_state) { // if zeo logo has already been displayed
     prepare_standard_screen(); // things that are displayed in every frame: title, date, time
  } // end if
    
  fill(255, 255, 255); // text font color set to white
    
  switch (program_state) {
    
    case load_logo_upon_startup_program_state: // where program starts
     
      background(255); // white background as logo is black
      imageMode(CENTER); // align logo with center of screen
      image(zeo_logo,  screen.width / 2, screen.height / 2); // display image to screen, will be rendered when end of draw function is reached

      program_state = pause_to_display_logo_upon_startup_program_state; // update program state to move on
      
      delay_duration = 0; // no delay desired
      
      break; // break out of selection process otherwise command under next case will execute
      
    case pause_to_display_logo_upon_startup_program_state:
    
      program_state = prompt_user_to_continue_or_exit_program_state; // update program state to move on
      
      delay_duration = 3000; // keep logo (previously rendered) displayed for 3 sec, make program hang for 3 sec
      
      break; // break out of selection process otherwise command under next case will execute
    
    case prompt_user_to_continue_or_exit_program_state: // where program starts
      
      textFont(fontA); // set font
      textSize(26); // set font size
      textAlign(CENTER, CENTER); // set font alignment
      
      text("Reminder: Files to be accessed must be placed in the data folder of this program.", screen.width / 2, screen.height / 2);
      text("Press ENTER to proceed or ESC to exit program.", screen.width / 2, screen.height / 2 + user_input_prompts_y_offset);
      
      delay_duration = 0; // no delay desired
      
      break; // break out of selection process otherwise command under next case will execute
          
    case prompt_user_for_file_naming_convention_program_state: // where program starts
      
      textFont(fontA); // set font
      textSize(26); // set font size
      textAlign(CENTER, CENTER); // set font alignment
      
      text("Does the name of the file to be loaded have a month and date? (Y/N)", screen.width / 2, screen.height / 2);
      
      delay_duration = 0; // no delay desired
      
      break; // break out of selection process otherwise command under next case will execute
      
    case prompt_user_for_month_of_file_name_program_state:
    
      textFont(fontA); // set font
      textSize(26); // set font size
      textAlign(CENTER, CENTER); // set font alignment
      
      text("Enter the month in the file name using two digit format (MM), e.g., 01 for January: ", screen.width / 2, screen.height / 2);
      
      delay_duration = 0; // no delay desired
      
      break; // break out of selection process otherwise command under next case will execute    
      
    case confirm_month_of_file_name_program_state:
    
      textFont(fontA); // set font
      textSize(26); // set font size
      textAlign(CENTER, CENTER); // set font alignment
      text("Is ", screen.width / 2, screen.height / 2 - user_input_prompts_y_offset);
      textAlign(CENTER, CENTER); // set font alignment
      textSize(40);
      text(file_name_month, screen.width / 2, screen.height / 2);
      textSize(26);
      textAlign(CENTER, CENTER); // set font alignment
      text("the correct month? (Y/N)", screen.width / 2, screen.height / 2 + user_input_prompts_y_offset);
      
      delay_duration = 0; // no delay desired
      
      break; // break out of selection process otherwise command under next case will execute
      
    case prompt_user_for_date_of_file_name_program_state:
    
      textFont(fontA); // set font
      textSize(26); // set font size
      textAlign(CENTER, CENTER); // set font alignment
      
      text("Enter the date in the file name using two digit format (DD), e.g., 01 for the 1st: ", screen.width / 2, screen.height / 2);
      
      delay_duration = 0; // no delay desired
      
      break; // break out of selection process otherwise command under next case will execute
       
    case confirm_date_of_file_name_program_state: 
    
      textFont(fontA); // set font
      textSize(26); // set font size
      textAlign(CENTER, CENTER); // set font alignment
      text("Is ", screen.width / 2, screen.height / 2 - user_input_prompts_y_offset);
      textAlign(CENTER, CENTER); // set font alignment
      textSize(40);
      text(file_name_date, screen.width / 2, screen.height / 2);
      textSize(26);
      textAlign(CENTER, CENTER); // set font alignment
      text("the correct date? (Y/N)", screen.width / 2, screen.height / 2 + user_input_prompts_y_offset);    
      
      delay_duration = 0; // no delay desired
      
      break; // break out of selection process otherwise command under next case will execute
      
    case load_data_from_files_program_state:
    
      load_data_from_files();
      
      delay_duration = 0; // no delay desired
      
      break; // break out of selection process otherwise command under next case will execute
      
    case prompt_user_for_desired_data_resolution_program_state:

      textFont(fontA); // set font
      textSize(26); // set font size
      textAlign(CENTER, CENTER); // set font alignment
      
      text("Enter the amount of data to display on the screen: ", screen.width / 2, screen.height / 2);
      text("3 minutes   (PRESS 'a')", screen.width / 2, (screen.height / 2) + 2 * user_input_prompts_y_offset);
      text("5 minutes   (PRESS 'b')", screen.width / 2, (screen.height / 2) + 3 * user_input_prompts_y_offset);
      text("10 minutes  (PRESS 'c')", screen.width / 2, (screen.height / 2) + 4 * user_input_prompts_y_offset);
      text("15 minutes  (PRESS 'd')", screen.width / 2, (screen.height / 2) + 5 * user_input_prompts_y_offset);
      text("30 minutes  (PRESS 'e')", screen.width / 2, (screen.height / 2) + 6 * user_input_prompts_y_offset);
      text("60 minutes  (PRESS 'f')", screen.width / 2, (screen.height / 2) + 7 * user_input_prompts_y_offset);
      
      delay_duration = 0; // no delay desired
      
      break; // break out of selection process otherwise command under next case will execute
      
    case viewing_data_program_state:
    
      plot_eeg_data(); // display eeg data
      plot_hypnogram_data(); // display sleep stage data
      display_key(); // display key for eeg data and key for sleep stage data
      
      textFont(fontB); // set font
      textSize(22); // set font size
      
      textAlign(LEFT, CENTER);
      text(eeg_file_name, gui_icon_x_start, screen.height / 2 + 2 * user_input_prompts_y_offset); // display name of eeg file being displayed
      
      textAlign(LEFT, CENTER);
      text(hypnogram_file_name, gui_icon_x_start, screen.height / 2 + 2.5 * user_input_prompts_y_offset); // display name of hypnogram file being displayed
      
      delay_duration = 0; // no delay desired
      
      break; // break out of selection process otherwise command under next case will execute    
     
  } // end of switch
  
  delay(delay_duration); // make program hang to allow what was rendered to be displayed before screen is refreshed
  
} // end of draw

// *****************************************************************************************************************************************************************************************

void load_data_from_files() {
  
  File file_to_load_1 = new File(dataPath(eeg_file_name));
  File file_to_load_2 = new File(dataPath(hypnogram_file_name));
      
  if ((file_to_load_1.exists()) && (file_to_load_2.exists())) { // make sure files exist
  
    eeg_data_file_array = loadStrings(eeg_file_name); // create and assign - file being read from must be placed within the data file of the processing sketch directory!
    hypnogram_data_file_array = loadStrings(hypnogram_file_name); // create and assign - file being read from must be placed within the data file of the processing sketch directory! 
  
    parse_eeg_time_stamp(); // parse eeg time stamps for alignment
    parse_hypnogram_time_stamp(); // parse sleep stage time stamps for alignment
    determination_of_least_common_time_stamp(); // determine least common time stamp to align eeg data with sleep stage data (start at same second)
    parse_eeg_data(); // parse eeg data
    parse_hypnogram_data(); // parse sleep stage data
 
    program_state = prompt_user_for_desired_data_resolution_program_state; // update to move on
    
  }
  
  else {
    
    textFont(fontA); // set font
    textSize(26); // set font size
    textAlign(CENTER, CENTER); // set font alignment
    
    text("Error: Specified file does not exist in the program's data folder.", screen.width / 2, screen.height / 2); 
    text("Press ENTER to return to the main menu.", screen.width / 2, screen.height / 2 + user_input_prompts_y_offset);
  
  }
      
  return;
 
} // end of load_data_from_files function
  
// *****************************************************************************************************************************************************************************************

void parse_eeg_time_stamp() {
  
  eeg_data_file_array_size = eeg_data_file_array.length; // get the raw size of the eeg data file array including header offset
  eeg_data_file_array_header_removed_size = eeg_data_file_array_size - file_header_offset; // subtract header offset to get processed size of eeg data file array (number of data items = array size + 1 as array index starts at zero!)
  eeg_data_file_array_header_removed = new String [eeg_data_file_array_header_removed_size]; // create - subset of sleep stage data file array with header removed (only data)
  arrayCopy(eeg_data_file_array, file_header_offset, eeg_data_file_array_header_removed, 0, eeg_data_file_array_header_removed_size); // assign - copy only data items to new array (omit header)
  
  // source array, starting location of source array, destination array, starting location of destination array, number of items to copy 

  eeg_data_unaligned_year_value_array = new int [eeg_data_file_array_header_removed_size]; // create array
  eeg_data_unaligned_month_value_array = new int [eeg_data_file_array_header_removed_size]; // create array
  eeg_data_unaligned_date_value_array = new int [eeg_data_file_array_header_removed_size]; // create array
  eeg_data_unaligned_hour_value_array = new int [eeg_data_file_array_header_removed_size]; // create array
  eeg_data_unaligned_minute_value_array = new int [eeg_data_file_array_header_removed_size]; // create array
  eeg_data_unaligned_second_value_array = new int [eeg_data_file_array_header_removed_size]; // create array
  
  for (array_pointer = 0; array_pointer < eeg_data_file_array_header_removed_size; array_pointer = array_pointer + 1) { // iterate through line by line
    
    single_line_from_eeg_data_file_array = eeg_data_file_array_header_removed[array_pointer]; // line 5 is first row with data so element 5 of string array becomes data to parse
    parsed_items = split(single_line_from_eeg_data_file_array, ","); // create and assign - parse the line, comma delimited values
    
    eeg_data_year_value = int(parsed_items[0]); // must cast as integer
    eeg_data_unaligned_year_value_array[array_pointer] = eeg_data_year_value; // assign value

    eeg_data_month_value = int(parsed_items[1]); // must cast as integer
    eeg_data_unaligned_month_value_array[array_pointer] = eeg_data_month_value; // assign value

    eeg_data_date_value = int(parsed_items[2]); // must cast as integer
    eeg_data_unaligned_date_value_array[array_pointer] = eeg_data_date_value; // assign value

    eeg_data_hour_value = int(parsed_items[3]); // must cast as integer
    eeg_data_unaligned_hour_value_array[array_pointer] = eeg_data_hour_value; // assign value

    eeg_data_minute_value = int(parsed_items[4]); // must cast as integer
    eeg_data_unaligned_minute_value_array[array_pointer] = eeg_data_minute_value; // assign value

    eeg_data_second_value = int(parsed_items[5]); // must cast as integer
    eeg_data_unaligned_second_value_array[array_pointer] = eeg_data_second_value; // assign value
    
  } // end of for
 
  return;
 
} // end of parse_eeg_time_stamp function

// *****************************************************************************************************************************************************************************************

void parse_hypnogram_time_stamp() {
  
  hypnogram_data_file_array_size = hypnogram_data_file_array.length; // get the raw size of the sleep stage data file including header offset
  hypnogram_data_file_array_header_removed_size = hypnogram_data_file_array_size - file_header_offset; // subtract header offset to get processed size of sleep stage data file array (number of data items = array size + 1 as array index starts at zero!)
  hypnogram_data_file_array_header_removed = new String [hypnogram_data_file_array_header_removed_size]; // create - subset of sleep stage data file array with header removed (only data)
  arrayCopy(hypnogram_data_file_array, file_header_offset, hypnogram_data_file_array_header_removed, 0, hypnogram_data_file_array_header_removed_size); // assign - copy only data items to new array (omit header)
 
  // source array, starting location of source array, destination array, starting location of destination array, number of items to copy 
  
  hypnogram_unaligned_year_value_array = new int [hypnogram_data_file_array_header_removed_size]; // create array
  hypnogram_unaligned_month_value_array = new int [hypnogram_data_file_array_header_removed_size]; // create array
  hypnogram_unaligned_date_value_array = new int [hypnogram_data_file_array_header_removed_size]; // create array
  hypnogram_unaligned_hour_value_array = new int [hypnogram_data_file_array_header_removed_size]; // create array
  hypnogram_unaligned_minute_value_array = new int [hypnogram_data_file_array_header_removed_size]; // create array
  hypnogram_unaligned_second_value_array = new int [hypnogram_data_file_array_header_removed_size]; // create array
  
  for (array_pointer = 0; array_pointer < hypnogram_data_file_array_header_removed_size; array_pointer = array_pointer + 1) { // iterate through line by line
   
    single_line_from_hypnogram_data_file_array = hypnogram_data_file_array_header_removed[array_pointer]; // line 5 is first row with dataso element 5 of string array becomes data to parse
    parsed_items = split(single_line_from_hypnogram_data_file_array, ","); // create and assign - parse the line, comma delimited values
 
    hypnogram_year_value = int(parsed_items[0]); // must cast as integer
    hypnogram_unaligned_year_value_array[array_pointer] = hypnogram_year_value; // assign value

    hypnogram_month_value = int(parsed_items[1]); // must cast as integer
    hypnogram_unaligned_month_value_array[array_pointer] = hypnogram_month_value; // assign value

    hypnogram_date_value = int(parsed_items[2]); // must cast as integer
    hypnogram_unaligned_date_value_array[array_pointer] = hypnogram_date_value; // assign value

    hypnogram_hour_value = int(parsed_items[3]); // must cast as integer
    hypnogram_unaligned_hour_value_array[array_pointer] = hypnogram_hour_value; // assign value

    hypnogram_minute_value = int(parsed_items[4]); // must cast as integer
    hypnogram_unaligned_minute_value_array[array_pointer] = hypnogram_minute_value; // assign value

    hypnogram_second_value = int(parsed_items[5]); // must cast as integer
    hypnogram_unaligned_second_value_array[array_pointer] = hypnogram_second_value; // assign value

  } // end of for 
 
  return;
  
} // end of parse_hypnogram_time_stamp function
  
// *****************************************************************************************************************************************************************************************

void determination_of_least_common_time_stamp() {
  
  // determine least common time stamp to align sleep stage data with eeg data
    
  while (found_least_common_time_stamp_program_flag == false) { // do until least common time stamp is found
    
    hypnogram_year_value = hypnogram_unaligned_year_value_array[hypnogram_data_array_pointer]; // assign value
    hypnogram_month_value = hypnogram_unaligned_month_value_array[hypnogram_data_array_pointer]; // assign value
    hypnogram_date_value = hypnogram_unaligned_date_value_array[hypnogram_data_array_pointer]; // assign value
    hypnogram_hour_value = hypnogram_unaligned_hour_value_array[hypnogram_data_array_pointer]; // assign value
    hypnogram_minute_value = hypnogram_unaligned_minute_value_array[hypnogram_data_array_pointer]; // assign value
    hypnogram_second_value = hypnogram_unaligned_second_value_array[hypnogram_data_array_pointer]; // assign value
  
    eeg_data_year_value = eeg_data_unaligned_year_value_array[eeg_data_array_pointer]; // assign value
    eeg_data_month_value = eeg_data_unaligned_month_value_array[eeg_data_array_pointer]; // assign value
    eeg_data_date_value = eeg_data_unaligned_date_value_array[eeg_data_array_pointer]; // assign value
    eeg_data_hour_value = eeg_data_unaligned_hour_value_array[eeg_data_array_pointer]; // assign value
    eeg_data_minute_value = eeg_data_unaligned_minute_value_array[eeg_data_array_pointer]; // assign value
    eeg_data_second_value = eeg_data_unaligned_second_value_array[eeg_data_array_pointer]; // assign value 
    
    if (hypnogram_year_value == eeg_data_year_value) { // if data share same year, move on to next comparison, if not, break out
      if (hypnogram_month_value == eeg_data_month_value) { // if data share same month, move on to next comparison, if not, break out
        if (hypnogram_date_value == eeg_data_date_value) { // if data share same date, move on to next comparison, if not, break out
          if (hypnogram_hour_value == eeg_data_hour_value) { // if data share same hour, move on to next comparison, if not, break out
            if (hypnogram_minute_value == eeg_data_minute_value) { // if data share same minute, move on to next comparison, if not, break out
              if (hypnogram_second_value == eeg_data_second_value) { // if data share same second, set flag, if not, break out
                
                // have found least common time stamp
                found_least_common_time_stamp_program_flag = true; // set found least common time stamp program flag
                
              } // end if
            } // end if
          } // end if
        } // end if
      } // end if
    } // end if
    
    if (found_least_common_time_stamp_program_flag == false) { // if have not found least common time stamp
      if (eeg_data_array_pointer < (eeg_data_file_array_header_removed_size - 1)) { // if not on last item in eeg data array
        eeg_data_array_pointer = eeg_data_array_pointer + 1; // increment eeg data array pointer
      }
      else if (eeg_data_array_pointer == (eeg_data_file_array_header_removed_size - 1)) { // if on last item in eeg data array
        if (hypnogram_data_array_pointer < (hypnogram_data_file_array_header_removed_size - 1)) { // if not on last iten in hypnogram data array - safeguard against out of range array reference
          hypnogram_data_array_pointer = hypnogram_data_array_pointer + 1; // increment hypnogram array pointer and
          eeg_data_array_pointer = 0; // reset eeg data array pointer to perform next alignment attempt
        }
        else if (hypnogram_data_array_pointer == (hypnogram_data_file_array_header_removed_size - 1)) { // if searched through entire sleep stage data array and failed to find least common time stamp
          exit(); // quit program to avoid out of range reference attempt 
        } // end if
      } // end if
    } // end if
    
  } // end of while
   
  return;
  
} // end of determination_of_least_common_time_stamp function
 
// *****************************************************************************************************************************************************************************************

void parse_eeg_data() {
  
  eeg_data_file_array_aligned_size = eeg_data_file_array_header_removed_size - eeg_data_array_pointer; // subtract array pointer offset to get size of eeg data file array starting from least common time stamp (number of data items = array size + 1 as array index starts at zero!)
  eeg_data_file_array_aligned = new String [eeg_data_file_array_aligned_size]; // create - subset of sleep stage data file array, from least common time stamp
  arrayCopy(eeg_data_file_array_header_removed, eeg_data_array_pointer, eeg_data_file_array_aligned, 0, eeg_data_file_array_aligned_size); // assign - copy items to new array starting from least common time stamp
 
  eeg_data_aligned_year_value_array = new int [eeg_data_file_array_aligned_size]; // create array
  eeg_data_aligned_month_value_array = new int [eeg_data_file_array_aligned_size]; // create array
  eeg_data_aligned_date_value_array = new int [eeg_data_file_array_aligned_size]; // create array
  eeg_data_aligned_hour_value_array = new int [eeg_data_file_array_aligned_size]; // create array
  eeg_data_aligned_minute_value_array = new int [eeg_data_file_array_aligned_size]; // create array
  eeg_data_aligned_second_value_array = new int [eeg_data_file_array_aligned_size]; // create array
  
  brain_wave_delta_absolute_array = new int [eeg_data_file_array_aligned_size]; // create array
  brain_wave_theta_absolute_array = new int [eeg_data_file_array_aligned_size]; // create array
  brain_wave_alpha_absolute_array = new int [eeg_data_file_array_aligned_size]; // create array
  brain_wave_beta_13_to_18_absolute_array = new int [eeg_data_file_array_aligned_size]; // create array
  brain_wave_beta_18_to_21_absolute_array = new int [eeg_data_file_array_aligned_size]; // create array
  brain_wave_beta_11_to_14_sleep_spindles_absolute_array = new int [eeg_data_file_array_aligned_size]; // create array
  brain_wave_gamma_absolute_array = new int [eeg_data_file_array_aligned_size]; // create array

  eeg_activity_total_array = new int [eeg_data_file_array_aligned_size]; // create array

  brain_wave_delta_relative_array = new float [eeg_data_file_array_aligned_size]; // create array
  brain_wave_theta_relative_array = new float [eeg_data_file_array_aligned_size]; // create array
  brain_wave_alpha_relative_array = new float [eeg_data_file_array_aligned_size]; // create array
  brain_wave_beta_13_to_18_relative_array = new float [eeg_data_file_array_aligned_size]; // create array
  brain_wave_beta_18_to_21_relative_array = new float [eeg_data_file_array_aligned_size]; // create array
  brain_wave_beta_11_to_14_sleep_spindles_relative_array = new float [eeg_data_file_array_aligned_size]; // create array
  brain_wave_gamma_relative_array = new float [eeg_data_file_array_aligned_size]; // create array
  
  for (array_pointer = 0; array_pointer < eeg_data_file_array_aligned_size; array_pointer = array_pointer + 1) { // iterate through line by line
    
    single_line_from_eeg_data_file_array = eeg_data_file_array_aligned[array_pointer]; // line by line
    parsed_items = split(single_line_from_eeg_data_file_array, ","); // create and assign - parse the line, comma separated values
    
    eeg_data_year_value = int(parsed_items[0]); // must cast as integer
    eeg_data_aligned_year_value_array[array_pointer] = eeg_data_year_value; // assign value

    eeg_data_month_value = int(parsed_items[1]); // must cast as integer
    eeg_data_aligned_month_value_array[array_pointer] = eeg_data_month_value; // assign value

    eeg_data_date_value = int(parsed_items[2]); // must cast as integer
    eeg_data_aligned_date_value_array[array_pointer] = eeg_data_date_value; // assign value

    eeg_data_hour_value = int(parsed_items[3]); // must cast as integer
    eeg_data_aligned_hour_value_array[array_pointer] = eeg_data_hour_value; // assign value

    eeg_data_minute_value = int(parsed_items[4]); // must cast as integer
    eeg_data_aligned_minute_value_array[array_pointer] = eeg_data_minute_value; // assign value

    eeg_data_second_value = int(parsed_items[5]); // must cast as integer
    eeg_data_aligned_second_value_array[array_pointer] = eeg_data_second_value; // assign value

    brain_wave_delta_absolute = int(parsed_items[6]); // must cast as integer
    brain_wave_delta_absolute_array[array_pointer] = brain_wave_delta_absolute; // assign value

    brain_wave_theta_absolute = int(parsed_items[7]); // must cast as integer
    brain_wave_theta_absolute_array[array_pointer] = brain_wave_theta_absolute; // assign value

    brain_wave_alpha_absolute = int(parsed_items[8]); // must cast as integer
    brain_wave_alpha_absolute_array[array_pointer] = brain_wave_alpha_absolute; // assign value

    brain_wave_beta_13_to_18_absolute = int(parsed_items[9]); // must cast as integer
    brain_wave_beta_13_to_18_absolute_array[array_pointer] = brain_wave_beta_13_to_18_absolute; // assign value

    brain_wave_beta_18_to_21_absolute = int(parsed_items[10]); // must cast as integer
    brain_wave_beta_18_to_21_absolute_array[array_pointer] = brain_wave_beta_18_to_21_absolute; // assign value

    brain_wave_beta_11_to_14_sleep_spindles_absolute = int(parsed_items[11]); // must cast as integer
    brain_wave_beta_11_to_14_sleep_spindles_absolute_array[array_pointer] = brain_wave_beta_11_to_14_sleep_spindles_absolute; // assign value

    brain_wave_gamma_absolute = int(parsed_items[12]); // must cast as integer
    brain_wave_gamma_absolute_array[array_pointer] = brain_wave_gamma_absolute; // assign value

    eeg_activity_total = int(parsed_items[13]); // must cast as integer
    eeg_activity_total_array[array_pointer] = eeg_activity_total; // assign value

    brain_wave_delta_relative = float(parsed_items[14]); // must cast as float
    brain_wave_delta_relative_array[array_pointer] = brain_wave_delta_relative; // assign value

    brain_wave_theta_relative = float(parsed_items[15]); // must cast as float
    brain_wave_theta_relative_array[array_pointer] = brain_wave_theta_relative; // assign value

    brain_wave_alpha_relative = float(parsed_items[16]); // must cast as float
    brain_wave_alpha_relative_array[array_pointer] = brain_wave_alpha_relative; // assign value

    brain_wave_beta_13_to_18_relative = float(parsed_items[17]); // must cast as float
    brain_wave_beta_13_to_18_relative_array[array_pointer] = brain_wave_beta_13_to_18_relative; // assign value

    brain_wave_beta_18_to_21_relative = float(parsed_items[18]); // must cast as float
    brain_wave_beta_18_to_21_relative_array[array_pointer] = brain_wave_beta_18_to_21_relative; // assign value

    brain_wave_beta_11_to_14_sleep_spindles_relative = float(parsed_items[19]); // must cast as float
    brain_wave_beta_11_to_14_sleep_spindles_relative_array[array_pointer] = brain_wave_beta_11_to_14_sleep_spindles_relative; // assign value
    
    brain_wave_gamma_relative = float(parsed_items[20]); // must cast as float
    brain_wave_gamma_relative_array[array_pointer] = brain_wave_gamma_relative; // assign value
    
  } // end of for
    
  eeg_array_max_value = max(brain_wave_delta_relative_array);
  if (eeg_array_max_value > eeg_array_global_max_value) {
    eeg_array_global_max_value = eeg_array_max_value; // find the overall (global) eeg max for scaling of data for display
  }  
  
  eeg_array_max_value = max(brain_wave_theta_relative_array);
  if (eeg_array_max_value > eeg_array_global_max_value) {
    eeg_array_global_max_value = eeg_array_max_value; // find the overall (global) eeg max for scaling of data for display
  }
  
  eeg_array_max_value = max(brain_wave_alpha_relative_array);
  if (eeg_array_max_value > eeg_array_global_max_value) {
    eeg_array_global_max_value = eeg_array_max_value; // find the overall (global) eeg max for scaling of data for display
  }  
  
  eeg_array_max_value = max(brain_wave_beta_13_to_18_relative_array);
  if (eeg_array_max_value > eeg_array_global_max_value) {
    eeg_array_global_max_value = eeg_array_max_value; // find the overall (global) eeg max for scaling of data for display
  }
  
  eeg_array_max_value = max(brain_wave_beta_18_to_21_relative_array);
  if (eeg_array_max_value > eeg_array_global_max_value) {
    eeg_array_global_max_value = eeg_array_max_value; // find the overall (global) eeg max for scaling of data for display
  }
  
  eeg_array_max_value = max(brain_wave_beta_11_to_14_sleep_spindles_relative_array);
  if (eeg_array_max_value > eeg_array_global_max_value) {
    eeg_array_global_max_value = eeg_array_max_value; // find the overall (global) eeg max for scaling of data for display
  }
  
  eeg_array_max_value = max(brain_wave_gamma_relative_array);
  if (eeg_array_max_value > eeg_array_global_max_value) {
    eeg_array_global_max_value = eeg_array_max_value; // find the overall (global) eeg max for scaling of data for display
  }
 
  return;
  
} // end of parse_eeg_data function

// *****************************************************************************************************************************************************************************************

void parse_hypnogram_data() { 
  
  hypnogram_file_data_array_aligned_size = hypnogram_data_file_array_header_removed_size - hypnogram_data_array_pointer; // subtract hypnogram array pointer offset to get size of sleep stage data file array from least common time stamp (number of data items = array size + 1 as array index starts at zero!)
  hypnogram_data_file_array_aligned = new String [hypnogram_file_data_array_aligned_size]; // create - subset of sleep stage data file array, from least common time stamp
  arrayCopy(hypnogram_data_file_array_header_removed, hypnogram_data_array_pointer, hypnogram_data_file_array_aligned, 0, hypnogram_file_data_array_aligned_size); // assign - copy items to new array, starting from least common time stamp

print("hypnogram_file_data_array_aligned_size");
println(hypnogram_file_data_array_aligned_size);

  maximum_guaranteed_eeg_data_array_pointer = ((hypnogram_file_data_array_aligned_size - 1) * 30); // max guaranteed eeg data array pointer, 30 eeg data points for every sleep stage determination

  print("maximum_guaranteed_eeg_data_array_pointer: ");
  println(maximum_guaranteed_eeg_data_array_pointer);
  
  hypnogram_aligned_year_value_array = new int [hypnogram_file_data_array_aligned_size]; // create array
  hypnogram_aligned_month_value_array = new int [hypnogram_file_data_array_aligned_size]; // create array
  hypnogram_aligned_date_value_array = new int [hypnogram_file_data_array_aligned_size]; // create array
  hypnogram_aligned_hour_value_array = new int [hypnogram_file_data_array_aligned_size]; // create array
  hypnogram_aligned_minute_value_array = new int [hypnogram_file_data_array_aligned_size]; // create array
  hypnogram_aligned_second_value_array = new int [hypnogram_file_data_array_aligned_size]; // create array

  zeo_sleep_stage_array = new int [hypnogram_file_data_array_aligned_size]; // create array
  sleep_stage_for_hypnogram_array = new int [hypnogram_file_data_array_aligned_size]; // create array
  sleep_stage_description_array = new String [hypnogram_file_data_array_aligned_size]; // create array
  
  for (array_pointer = 0; array_pointer < hypnogram_file_data_array_aligned_size; array_pointer = array_pointer + 1) { // iterate through line by line
   
    single_line_from_hypnogram_data_file_array = hypnogram_data_file_array_aligned[array_pointer]; // line by line
    parsed_items = split(single_line_from_hypnogram_data_file_array, ","); // create and assign - parse the line, comma delimited values
 
    hypnogram_year_value = int(parsed_items[0]); // must cast as integer
    hypnogram_aligned_year_value_array[array_pointer] = hypnogram_year_value; // assign value

    hypnogram_month_value = int(parsed_items[1]); // must cast as integer
    hypnogram_aligned_month_value_array[array_pointer] = hypnogram_month_value; // assign value

    hypnogram_date_value = int(parsed_items[2]); // must cast as integer
    hypnogram_aligned_date_value_array[array_pointer] = hypnogram_date_value; // assign value

    hypnogram_hour_value = int(parsed_items[3]); // must cast as integer
    hypnogram_aligned_hour_value_array[array_pointer] = hypnogram_hour_value; // assign value

    hypnogram_minute_value = int(parsed_items[4]); // must cast as integer
    hypnogram_aligned_minute_value_array[array_pointer] = hypnogram_minute_value; // assign value

    hypnogram_second_value = int(parsed_items[5]); // must cast as integer
    hypnogram_aligned_second_value_array[array_pointer] = hypnogram_second_value; // assign value

    zeo_sleep_stage = int(parsed_items[6]); // must cast as integer
    zeo_sleep_stage_array[array_pointer] = zeo_sleep_stage; // assign value
    
    sleep_stage_for_hypnogram = int(parsed_items[7]); // must cast as integer
    sleep_stage_for_hypnogram_array[array_pointer] = sleep_stage_for_hypnogram; // assign value
    
    sleep_stage_description = parsed_items[8];
    sleep_stage_description_array[array_pointer] =  sleep_stage_description; // assign value, parsed sleep stage description already a string so don't need to convert data type

  } // end of for 
  
  return;
  
} // end of parse_hypnogram_data function

// *****************************************************************************************************************************************************************************************

void plot_eeg_data() {
  
  for (eeg_data_array_pointer = eeg_data_array_pointer_start; eeg_data_array_pointer <= eeg_data_array_pointer_end; eeg_data_array_pointer = eeg_data_array_pointer + 1) { // iterate through array
    
    brain_wave_delta_relative = brain_wave_delta_relative_array[eeg_data_array_pointer];
    brain_wave_theta_relative = brain_wave_theta_relative_array[eeg_data_array_pointer];
    brain_wave_alpha_relative = brain_wave_alpha_relative_array[eeg_data_array_pointer];
    brain_wave_beta_13_to_18_relative = brain_wave_beta_13_to_18_relative_array[eeg_data_array_pointer];
    brain_wave_beta_18_to_21_relative = brain_wave_beta_18_to_21_relative_array[eeg_data_array_pointer];
    brain_wave_beta_11_to_14_sleep_spindles_relative = brain_wave_beta_11_to_14_sleep_spindles_relative_array[eeg_data_array_pointer];
    brain_wave_gamma_relative = brain_wave_gamma_relative_array[eeg_data_array_pointer]; // assign value
            
    brain_wave_delta_relative_pixel_location_raw = map(brain_wave_delta_relative, 0, eeg_array_global_max_value, eeg_data_display_vertical_end, eeg_data_display_vertical_start); // rescale for display, reverse order of lower and upper bounds to avoid having to take complement to get data to display properly (bottom to top rather than top to bottom)
    brain_wave_theta_relative_pixel_location_raw = map(brain_wave_theta_relative, 0, eeg_array_global_max_value, eeg_data_display_vertical_end, eeg_data_display_vertical_start); // rescale for display, reverse order of lower and upper bounds to avoid having to take complement to get data to display properly (bottom to top rather than top to bottom)
    brain_wave_alpha_relative_pixel_location_raw = map(brain_wave_alpha_relative, 0, eeg_array_global_max_value, eeg_data_display_vertical_end, eeg_data_display_vertical_start); // rescale for display, reverse order of lower and upper bounds to avoid having to take complement to get data to display properly (bottom to top rather than top to bottom)
    brain_wave_beta_13_to_18_relative_pixel_location_raw = map(brain_wave_beta_13_to_18_relative, 0, eeg_array_global_max_value, eeg_data_display_vertical_end, eeg_data_display_vertical_start); // rescale for display, reverse order of lower and upper bounds to avoid having to take complement to get data to display properly (bottom to top rather than top to bottom)
    brain_wave_beta_18_to_21_relative_pixel_location_raw = map(brain_wave_beta_18_to_21_relative, 0, eeg_array_global_max_value, eeg_data_display_vertical_end, eeg_data_display_vertical_start); // rescale for display, reverse order of lower and upper bounds to avoid having to take complement to get data to display properly (bottom to top rather than top to bottom)
    brain_wave_beta_11_to_14_sleep_spindles_relative_pixel_location_raw = map(brain_wave_beta_11_to_14_sleep_spindles_relative, 0, eeg_array_global_max_value, eeg_data_display_vertical_end, eeg_data_display_vertical_start); // rescale for display, reverse order of lower and upper bounds to avoid having to take complement to get data to display properly (bottom to top rather than top to bottom)
    brain_wave_gamma_relative_pixel_location_raw = map(brain_wave_gamma_relative, 0, eeg_array_global_max_value, eeg_data_display_vertical_end, eeg_data_display_vertical_start); // rescale for display, reverse order of lower and upper bounds to avoid having to take complement to get data to display properly (bottom to top rather than top to bottom)
      
    brain_wave_delta_relative_pixel_location = round(brain_wave_delta_relative_pixel_location_raw); // round to nearest integer value - essential as for some reason using float values occasionally results in no pixel appearing on screen
    brain_wave_theta_relative_pixel_location = round(brain_wave_theta_relative_pixel_location_raw); // round to nearest integer value - essential as for some reason using float values occasionally results in no pixel appearing on screen  
    brain_wave_alpha_relative_pixel_location = round(brain_wave_alpha_relative_pixel_location_raw); // round to nearest integer value - essential as for some reason using float values occasionally results in no pixel appearing on screen
    brain_wave_beta_13_to_18_relative_pixel_location = round(brain_wave_beta_13_to_18_relative_pixel_location_raw); // round to nearest integer value - essential as for some reason using float values occasionally results in no pixel appearing on screen
    brain_wave_beta_18_to_21_relative_pixel_location = round(brain_wave_beta_18_to_21_relative_pixel_location_raw); // round to nearest integer value - essential as for some reason using float values occasionally results in no pixel appearing on screen
    brain_wave_beta_11_to_14_sleep_spindles_relative_pixel_location = round(brain_wave_beta_11_to_14_sleep_spindles_relative_pixel_location_raw); // round to nearest integer value - essential as for some reason using float values occasionally results in no pixel appearing on screen
    brain_wave_gamma_relative_pixel_location = round(brain_wave_gamma_relative_pixel_location_raw); // round to nearest integer value - essential as for some reason using float values occasionally results in no pixel appearing on screen
      
    // int() would simply truncate float value, not round properly i.e. if x = 24.9, int(x) would return 24 while round would return 25
           
    time_pixel_location_eeg_raw = map(eeg_data_array_pointer, eeg_data_array_pointer_start, eeg_data_array_pointer_end, data_display_horizontal_start, data_display_horizontal_end); // eeg data rate is 1 / sec
    time_pixel_location_eeg = round(time_pixel_location_eeg_raw); // round to nearest integer

    strokeWeight(2); // line thickenss = 2 pixels wide

    stroke(255, 0, 0); // set color
    if (icon_eeg_display_toggle_state_delta) { // if TRUE
      point(time_pixel_location_eeg, brain_wave_delta_relative_pixel_location);
    } // end if
      
    stroke(0, 255, 0); // set color
    if (icon_eeg_display_toggle_state_theta) { // if TRUE
      point(time_pixel_location_eeg, brain_wave_theta_relative_pixel_location);
    } // end if
      
    stroke(0, 0, 255); // set color
    if (icon_eeg_display_toggle_state_alpha) { // if TRUE
      point(time_pixel_location_eeg, brain_wave_alpha_relative_pixel_location);
    } // end if
      
    stroke(255, 255, 0); // set color
    if (icon_eeg_display_toggle_state_beta_13_to_18){ // if TRUE
      point(time_pixel_location_eeg, brain_wave_beta_13_to_18_relative_pixel_location);   
    } // end if
      
    stroke(255, 0, 255); // set color
    if (icon_eeg_display_toggle_state_beta_18_to_21) { // if TRUE
      point(time_pixel_location_eeg, brain_wave_beta_18_to_21_relative_pixel_location);
    } // end if
      
    stroke(0, 255, 255); // set color
    if (icon_eeg_display_toggle_state_beta_sleep_spindles) { // if TRUE
      point(time_pixel_location_eeg, brain_wave_beta_11_to_14_sleep_spindles_relative_pixel_location); 
    } // end if
      
    stroke(255, 255, 255); // set color
    if (icon_eeg_display_toggle_state_gamma) { // if TRUE
      point(time_pixel_location_eeg, brain_wave_gamma_relative_pixel_location);         
    } // end if
      
    if (eeg_data_array_pointer > 0) { // join points using line segments starting with second point - for first point, there is no prior point from which to draw a line
        
      if (time_pixel_location_eeg > time_pixel_location_eeg_old) { // advancing through the data makes time_pixel_location_old (far right of screen) larger than time_pixel_location (far left of screen) - results in line extending from far right of screen (old) to far left of screen (new)
        
        stroke(255, 0, 0); // set color
        if (icon_eeg_display_toggle_state_delta) { // if TRUE
          line(time_pixel_location_eeg_old, brain_wave_delta_relative_pixel_location_old, time_pixel_location_eeg, brain_wave_delta_relative_pixel_location); // must use screen height's complement to plot from bottom to top rather than from top to bottom  
        } // end if
          
        stroke(0, 255, 0); // set color
        if (icon_eeg_display_toggle_state_theta) { // if TRUE
          line(time_pixel_location_eeg_old, brain_wave_theta_relative_pixel_location_old, time_pixel_location_eeg, brain_wave_theta_relative_pixel_location); // must use screen height's complement to plot from bottom to top rather than from top to bottom  
        } // end if
          
        stroke(0, 0, 255); // set color
        if (icon_eeg_display_toggle_state_alpha) { // if TRUE
          line(time_pixel_location_eeg_old, brain_wave_alpha_relative_pixel_location_old, time_pixel_location_eeg, brain_wave_alpha_relative_pixel_location); // must use screen height's complement to plot from bottom to top rather than from top to bottom  
        } // end if
          
        stroke(255, 255, 0); // set color
        if (icon_eeg_display_toggle_state_beta_13_to_18) { // if TRUE
          line(time_pixel_location_eeg_old, brain_wave_beta_13_to_18_relative_pixel_location_old, time_pixel_location_eeg, brain_wave_beta_13_to_18_relative_pixel_location); // must use screen height's complement to plot from bottom to top rather than from top to bottom  
        } // end if
          
        stroke(255, 0, 255);  // set color
        if (icon_eeg_display_toggle_state_beta_18_to_21) { // if TRUE
          line(time_pixel_location_eeg_old, brain_wave_beta_18_to_21_relative_pixel_location_old, time_pixel_location_eeg, brain_wave_beta_18_to_21_relative_pixel_location); // must use screen height's complement to plot from bottom to top rather than from top to bottom  
        } // end if
          
        stroke(0, 255, 255); // set color
        if (icon_eeg_display_toggle_state_beta_sleep_spindles) { // if TRUE
          line(time_pixel_location_eeg_old, brain_wave_beta_11_to_14_sleep_spindles_relative_pixel_location_old, time_pixel_location_eeg, brain_wave_beta_11_to_14_sleep_spindles_relative_pixel_location); // must use screen height's complement to plot from bottom to top rather than from top to bottom  
        } // end if
          
        stroke(255, 255, 255); // set color
        if (icon_eeg_display_toggle_state_gamma) { // if TRUE
          line(time_pixel_location_eeg_old, brain_wave_gamma_relative_pixel_location_old, time_pixel_location_eeg, brain_wave_gamma_relative_pixel_location); // must use screen height's complement to plot from bottom to top rather than from top to bottom  
        } // end if
          
      } // end if
      
    } // end if
      
    brain_wave_delta_relative_pixel_location_old = brain_wave_delta_relative_pixel_location; // update
    brain_wave_theta_relative_pixel_location_old = brain_wave_theta_relative_pixel_location; // update 
    brain_wave_alpha_relative_pixel_location_old = brain_wave_alpha_relative_pixel_location; // update
    brain_wave_beta_13_to_18_relative_pixel_location_old = brain_wave_beta_13_to_18_relative_pixel_location; // update
    brain_wave_beta_18_to_21_relative_pixel_location_old = brain_wave_beta_18_to_21_relative_pixel_location; // update
    brain_wave_beta_11_to_14_sleep_spindles_relative_pixel_location_old = brain_wave_beta_11_to_14_sleep_spindles_relative_pixel_location; // update
    brain_wave_gamma_relative_pixel_location_old = brain_wave_gamma_relative_pixel_location; // update

    time_pixel_location_eeg_old = time_pixel_location_eeg; // update
      
  } // end of for
   
  return;

} // end of plot_eeg_data function

// *****************************************************************************************************************************************************************************************

void plot_hypnogram_data() {
  
  for (hypnogram_data_array_pointer = hypnogram_data_array_pointer_start; hypnogram_data_array_pointer <= hypnogram_data_array_pointer_end; hypnogram_data_array_pointer = hypnogram_data_array_pointer + 1) { // iterate through array
  
    zeo_sleep_stage = zeo_sleep_stage_array[hypnogram_data_array_pointer];
    hypnogram_month_value = hypnogram_aligned_month_value_array[hypnogram_data_array_pointer];
    hypnogram_date_value = hypnogram_aligned_date_value_array[hypnogram_data_array_pointer];
    hypnogram_hour_value = hypnogram_aligned_hour_value_array[hypnogram_data_array_pointer];
    hypnogram_minute_value = hypnogram_aligned_minute_value_array[hypnogram_data_array_pointer];
    hypnogram_second_value = hypnogram_aligned_second_value_array[hypnogram_data_array_pointer]; // assign value
          
    hypnogram_pixel_location_raw = map(zeo_sleep_stage, 0, 4, hypnogram_display_vertical_start, hypnogram_display_vertical_end); // rescale for display
    hypnogram_pixel_location = round(hypnogram_pixel_location_raw); // round to nearest integer value - essential as for some reason using float values occasionally results in no pixel appearing on screen
     
    time_pixel_location_hypnogram_raw = map(hypnogram_data_array_pointer, hypnogram_data_array_pointer_start, hypnogram_data_array_pointer_end, data_display_horizontal_start, data_display_horizontal_end); // align with eeg data
    time_pixel_location_hypnogram = round(time_pixel_location_hypnogram_raw); // round to nearest integer
     
    stroke(255, 255, 255); // set color
    strokeWeight(7); // make pointer wider to indicate when Zeo made a sleep stage determination
    point(time_pixel_location_hypnogram, hypnogram_pixel_location);
    strokeWeight(1); // go back to points and lines being 1 pixel wide
    stroke(255, 255, 255, 50); // set color and transparency of grid lines
    line(time_pixel_location_hypnogram, eeg_data_display_vertical_start, time_pixel_location_hypnogram, hypnogram_display_vertical_end); // grid line every 30 sec 
     
    textAlign(CENTER, CENTER);
    fill(255, 255, 255);
     
    switch (minutes_of_data_to_display) { // set font size depending on resolution 
      case 3:
        textSize(18);
        display_key_x_offset_multiplier = 5;
        break; // break out of selection process otherwise command under next case will execute
      case 5:
        textSize(16);
        display_key_x_offset_multiplier = 4;        
        break; // break out of selection process otherwise command under next case will execute
      case 10:
        textSize(10);
        display_key_x_offset_multiplier = 2;
        break; // break out of selection process otherwise command under next case will execute
      case 15:
        textSize(8);
        display_key_x_offset_multiplier = 2;
        break; // break out of selection process otherwise command under next case will execute
      case 30:
        textSize(4);
        display_key_x_offset_multiplier = 1;  
        break; // break out of selection process otherwise command under next case will execute
      case 60:
        textSize(2);
        display_key_x_offset_multiplier = 1;
        break; // break out of selection process otherwise command under next case will execute
    } // end of switch statement   
    
    text(hypnogram_month_value, time_pixel_location_hypnogram - (display_key_x_offset_multiplier * display_key_x_offset), (screen.height + hypnogram_display_vertical_end) / 2);
    text("/",time_pixel_location_hypnogram, (screen.height + hypnogram_display_vertical_end) / 2);
    text(hypnogram_date_value, time_pixel_location_hypnogram + (display_key_x_offset_multiplier * display_key_x_offset), (screen.height + hypnogram_display_vertical_end) / 2);
     
    text(hypnogram_hour_value, time_pixel_location_hypnogram - (display_key_x_offset_multiplier * display_key_x_offset), (screen.height + hypnogram_display_vertical_end) / 2 + display_key_y_offset);
    text(":",time_pixel_location_hypnogram - (display_key_x_offset_multiplier / 2 * display_key_x_offset), (screen.height + hypnogram_display_vertical_end) / 2 + display_key_y_offset);
    text(hypnogram_minute_value, time_pixel_location_hypnogram, (screen.height + hypnogram_display_vertical_end) / 2 + display_key_y_offset);
    text(":",time_pixel_location_hypnogram + (display_key_x_offset_multiplier / 2 * display_key_x_offset), (screen.height + hypnogram_display_vertical_end) / 2 + display_key_y_offset);
    text(hypnogram_second_value, time_pixel_location_hypnogram + (display_key_x_offset_multiplier*display_key_x_offset), (screen.height + hypnogram_display_vertical_end) / 2 + display_key_y_offset); 
  
    // label grid lines with date and time
     
    stroke(255, 255, 255, 255); // set color and transparency

    if (hypnogram_data_array_pointer > 0) { // connect points using line segments
     
      if (time_pixel_location_hypnogram > time_pixel_location_hypnogram_old) { // advancing through the data makes time_pixel_location_old (far right of screen) larger than time_pixel_location (far left of screen) - results in line extending from far right of screen (old) to far left of screen (new)
       
        line(time_pixel_location_hypnogram_old, hypnogram_pixel_location_old, time_pixel_location_hypnogram, hypnogram_pixel_location_old); // horizontal line segment to connect dots
       
        if (hypnogram_pixel_location != hypnogram_pixel_location_old) {
          line(time_pixel_location_hypnogram, hypnogram_pixel_location_old, time_pixel_location_hypnogram, hypnogram_pixel_location); // vertical line segment needed to transition between stages
        } // end if
         
      } // end if
       
    } // end if

    hypnogram_pixel_location_old = hypnogram_pixel_location; // update
    time_pixel_location_hypnogram_old = time_pixel_location_hypnogram; // update

  } // end of for

  return;
    
} // end of plot_hypnogram_data function

// *****************************************************************************************************************************************************************************************

void display_key() {

  textFont(fontB); // set font
  textSize(22); // set font size
  textAlign(LEFT, CENTER); // set font alignment
  
  rectMode(CENTER); // set mode for icons
  stroke(0); // border is black, no white border of icons
  strokeWeight(3); // set line thickness = 3 pixels
  
  fill(255, 0, 0); // set color
  text("Delta (2-4 Hz)", display_key_x, display_key_y);
  
  if (icon_eeg_display_toggle_state_delta) { // if true
    stroke(0); // set line color to black to match background
    fill(255, 0, 0); // set fill color to match data and text color
  } // end if
  
  else { // if false
    stroke(255); // set line color to white to contrast with background
    fill(0, 0, 0); // set fill color to black to match background
  } // end else
  
  rect(legend_toggle_icon_x, display_key_y, legend_toggle_icon_width, legend_toggle_icon_height); // render icon

  fill(0, 255, 0); // set color
  text("Theta (4-8 Hz)", display_key_x, display_key_y + display_key_y_offset);
  
  if (icon_eeg_display_toggle_state_theta) { // if true
    stroke(0); // set line color to black to match background
    fill(0, 255, 0); // set fill color to match data and text color
  }  // end if
  
  else { // if false
    stroke(255); // set line color to white to contrast with background
    fill(0, 0, 0); // set fill color to black to match background
  } // end else
  
  rect(legend_toggle_icon_x, display_key_y + display_key_y_offset, legend_toggle_icon_width, legend_toggle_icon_height); // render icon
  
  fill(0, 0, 255); // set color
  text("Alpha (8-13 Hz)", display_key_x, display_key_y + 2 * display_key_y_offset);
  
  if (icon_eeg_display_toggle_state_alpha) { // if true
    stroke(0); // set line color to black to match background
    fill(0, 0, 255); // set fill color to match data and text color
  } // end if
  
  else { // if false
    stroke(255); // set line color to white to contrast with background
    fill(0, 0, 0); // set fill color to black to match background
  } // end else
  
  rect(legend_toggle_icon_x, display_key_y + 2 * display_key_y_offset, legend_toggle_icon_width, legend_toggle_icon_height); // render icon
 
  fill(255, 255, 0); // set color
  text("Beta (13-18 Hz)", display_key_x, display_key_y + 3 * display_key_y_offset);
  
  if (icon_eeg_display_toggle_state_beta_13_to_18) { // if true
    stroke(0); // set line color to black to match background
    fill(255, 255, 0); // set fill color to match data and text color
  } // end if
  
  else { // if false
    stroke(255); // set line color to white to contrast with background
    fill(0, 0, 0); // set fill color to black to match background
  } // end else
  
  rect(legend_toggle_icon_x, display_key_y + 3 * display_key_y_offset, legend_toggle_icon_width, legend_toggle_icon_height); // render icon

  fill(255, 0, 255); // set color
  text("Beta (18-21 Hz)", display_key_x, display_key_y + 4 * display_key_y_offset);
  
  if (icon_eeg_display_toggle_state_beta_18_to_21) { // if true
    stroke(0); // set line color to black to match background
    fill(255, 0, 255); // set fill color to match data and text color
  } // end if
  
  else { // if false
    stroke(255); // set line color to white to contrast with background
    fill(0, 0, 0); // set fill color to black to match background
  } // end else
  
  rect(legend_toggle_icon_x, display_key_y + 4 * display_key_y_offset, legend_toggle_icon_width, legend_toggle_icon_height); // render icon

  fill(0, 255, 255); // set color
  text("Beta (11-14 Hz)", display_key_x, display_key_y + 5 * display_key_y_offset);
  text("(Sleep Spindles)", display_key_x, display_key_y + 6 * display_key_y_offset);
  
  if (icon_eeg_display_toggle_state_beta_sleep_spindles) { // if true
    stroke(0); // set line color to black to match background
    fill(0, 255, 255); // set fill color to match data and text color
  } // end if
  
  else { // if false
    stroke(255); // set line color to white to contrast with background
    fill(0, 0, 0); // set fill color to black to match background
  } // end else
  
  rect(legend_toggle_icon_x, display_key_y + 5 * display_key_y_offset, legend_toggle_icon_width, legend_toggle_icon_height); // render icon
 
  fill(255, 255, 255); // set color
  textSize(18); // set font size
  
  text("Gamma (30-50 Hz)", display_key_x, display_key_y + 7 * display_key_y_offset);
  
  if (icon_eeg_display_toggle_state_gamma) { // if true
    stroke(0); // set line color to black to match background
    fill(255, 255, 255); // set fill color to match data and text color
  } // end if
  
  else { // if false
    stroke(255); // set line color to white to contrast with background
    fill(0, 0, 0); // set fill color to black to match background
  } // end else
  
  rect(legend_toggle_icon_x, display_key_y + 7 * display_key_y_offset, legend_toggle_icon_width, legend_toggle_icon_height); // render icon
  
  fill(255, 255, 255); // for text color in case display gamma gets toggled
  textSize(22); // set font size
  
  textAlign(LEFT,CENTER);
  text("UNK", display_key_x, hypnogram_display_vertical_start);
  text("AWK", display_key_x, hypnogram_display_vertical_start + hypnogram_key_y_offset);
  text("REM", display_key_x, hypnogram_display_vertical_start + 2 * hypnogram_key_y_offset);
  text("L", display_key_x, hypnogram_display_vertical_start + 3 * hypnogram_key_y_offset);
  text("D", display_key_x, hypnogram_display_vertical_end);
  
  relative_power_scale_value = int(eeg_array_global_max_value / 10);
  
  upper_limit_of_eeg_scale_raw = map(10 * relative_power_scale_value, 0, eeg_array_global_max_value, eeg_data_display_vertical_end, eeg_data_display_vertical_start); // scale for display
  upper_limit_of_eeg_scale = round(upper_limit_of_eeg_scale_raw); // round to nearest integer value
  
  textSize(20); // set font size
  textAlign(LEFT, CENTER);

  text("PWR", 0, eeg_data_display_vertical_start + ((eeg_data_display_vertical_end - eeg_data_display_vertical_start) / 2));
  text("(%)", 0, eeg_data_display_vertical_start + ((eeg_data_display_vertical_end - eeg_data_display_vertical_start) / 2) + display_key_y_offset);

  text("SLEEP", 0, hypnogram_display_vertical_start + ((hypnogram_display_vertical_end - hypnogram_display_vertical_start) / 2));
  text("STAGE", 0, hypnogram_display_vertical_start + ((hypnogram_display_vertical_end -  hypnogram_display_vertical_start) / 2) + display_key_y_offset);
  
  stroke(255, 255, 255, 50); // set color and transparency of grid lines
  strokeWeight(1); // set line thickness = 3 pixels

  for (relative_power_scale_counter = 0; relative_power_scale_counter <= 10; relative_power_scale_counter = relative_power_scale_counter + 1) {
    
    relative_power_scale_pixel_location_raw = map(relative_power_scale_counter, 0, 10, eeg_data_display_vertical_end, upper_limit_of_eeg_scale); // scale for display
    relative_power_scale_pixel_location = round(relative_power_scale_pixel_location_raw); // round to nearest integer value
    line(data_display_horizontal_start, relative_power_scale_pixel_location, data_display_horizontal_end, relative_power_scale_pixel_location); // horiz power grid lines
    textAlign(RIGHT, CENTER);
    text(relative_power_scale_value * relative_power_scale_counter, data_display_horizontal_start, relative_power_scale_pixel_location); // label value of power grid lines

  } // end of for
  
  return;
  
} // end of display_key function

// *****************************************************************************************************************************************************************************************

void prepare_standard_screen() {
  
  background(0); // clear screen - essential for proper display, black background
  fill(255, 255, 255); // keep text color white - otherwise it will change with bargraph - only want bargraph to change color depending on applied force, white text
   
  textFont(fontA); // set font
  textSize(38); // set font size
  textAlign(CENTER, TOP); // set font alignment
    
  text("Zeo Sleep Coach Data Visualization Program", screen.width / 2, 0);
    
  seconds_to_display = second(); // current second
  minutes_to_display = minute(); // current minute
  hours_to_display = hour(); // current hour
  
  days_to_display = day(); // current day
  months_to_display = month(); // current month
  years_to_display = year(); // current year
   
  switch (months_to_display) {
    case 1: 
      month_name = "JAN";
      break; // break out of selection process otherwise command under next case will execute
    case 2: 
      month_name = "FEB";
      break; // break out of selection process otherwise command under next case will execute
    case 3: 
      month_name = "MAR";
      break; // break out of selection process otherwise command under next case will execute
    case 4: 
      month_name = "APR";
      break; // break out of selection process otherwise command under next case will execute
    case 5: 
      month_name = "MAY";
      break; // break out of selection process otherwise command under next case will execute
    case 6: 
      month_name = "JUN";
      break; // break out of selection process otherwise command under next case will execute
    case 7: 
      month_name = "JUL";
      break; // break out of selection process otherwise command under next case will execute
    case 8: 
      month_name = "AUG";
      break; // break out of selection process otherwise command under next case will execute
    case 9: 
      month_name = "SEP";
      break; // break out of selection process otherwise command under next case will execute
    case 10: 
      month_name = "OCT";
      break; // break out of selection process otherwise command under next case will execute
    case 11: 
      month_name = "NOV";
      break; // break out of selection process otherwise command under next case will execute
    case 12: 
      month_name = "DEC";
      break; // break out of selection process otherwise command under next case will execute
  } // end of switch statement to determine month name
      
  textFont(fontA); //set font 
  textSize(16); // set font size
    
  textAlign(LEFT, TOP);
  text("DATE: ", 0, 0); 
  text(month_name, 1 * screen.width / 20, 0);
  text(days_to_display, 1.75 * screen.width / 20, 0);
  text(years_to_display, 2.25 * screen.width / 20 + 3, 0); // display month, date, year - change from numerical format to name i.e. if month = 7, then print july - superior, more friendly format
    
  textAlign(RIGHT, TOP);
  text("TIME: ", screen.width - 2.5 * screen.width / 20, 0);
  text(hours_to_display, screen.width - 2 * screen.width / 20, 0);
  text(":", screen.width - 1.5 * screen.width / 20, 0);
  text(minutes_to_display, screen.width - 1 * screen.width / 20, 0);
  text(":", screen.width - .5 * screen.width / 20, 0);
  text(seconds_to_display, screen.width, 0); // display current time

  stroke(0, 0, 0); // set line color to black
  strokeWeight(3); // set line thickness to divide icons
    
  rectMode(CORNER); // set mode for drawing icons
  rect(gui_icon_x_start, gui_icon_y_start, 150, 50); // upper left corner x, upper left corner y, width, height
  
  rectMode(CENTER);
  rect(gui_icon_x_end - 50, screen.height / 2, 100, 50); // upper left corner x, upper left corner y, width, height
        
  strokeWeight(3);
  line(gui_icon_x_end- 50, gui_icon_y_start, gui_icon_x_end - 50, gui_icon_y_end); // create vertical line to create separate icons
  line(gui_icon_x_end - 100, gui_icon_y_start, gui_icon_x_end - 100, gui_icon_y_end); // create vertical line to create separate icons
  line(gui_icon_x_end - 50, screen.height / 2 - 25, gui_icon_x_end - 50, screen.height / 2 + 25); // create vertical line to create separate icons
   
  fill(0, 0, 0); // set font color to black
  textFont(fontB); // set font
  textSize(20); // set font size
  textAlign(CENTER, CENTER); // center text both horizontally and vertically
    
  text("EXIT", gui_icon_x_end - 25, (gui_icon_y_start + (gui_icon_y_end - gui_icon_y_start) / 2)); // center in icon box  
  text("MAIN", gui_icon_x_end - 75, (gui_icon_y_start + (gui_icon_y_end - gui_icon_y_start) / 2)); // center in icon box 
  text("CAPT", gui_icon_x_end - 125, (gui_icon_y_start + (gui_icon_y_end - gui_icon_y_start) / 2)); // center in icon box
  text("NEXT", gui_icon_x_end - 25, screen.height / 2); // center in icon box  
  text("PREV", gui_icon_x_end - 75, screen.height / 2); // center in icon box   
  
  return;
     
} // end of prepare_standard_screen function

// *****************************************************************************************************************************************************************************************

void keyReleased() { // called when a key is released, action that results depends on user input and current state of program (where it is when input occurs), ignore invalid input (invalid choice or invalid time of entry) 
                     // use keyReleased rather than keyPressed to avoid issue of registering a single keystroke as multiple keystrokes - ensures that only discrete keystrokes are counted
  
  switch (program_state) {
    
    case prompt_user_to_continue_or_exit_program_state:
      
      if (key == ENTER) { // enter to proceed
        program_state = prompt_user_for_file_naming_convention_program_state;
      } // end of if key check
      
      else if (key == ESC) { // esc to exit program
        exit(); // exit program
      } // end of if key check
      
      break; // break out of selection process otherwise command under next case will execute
      
    case prompt_user_for_file_naming_convention_program_state:
  
      if ((key == 'y')||(key == 'Y')) { // if user input is valid. Prompt will remain displayed until valid user input entered. Accept upper and lower case. 
        program_state = prompt_user_for_month_of_file_name_program_state; // if file name has month and date, update program state to move on
      } // end of if key check
      
      else if ((key == 'n')||(key == 'N')) { // if user input is valid. Prompt will remain displayed until valid user input entered. Accept upper and lower case.
        eeg_file_name = "EEGDATA.CSV"; // if file name isn't stamped with month and date, use file name for single night
        hypnogram_file_name = "HYPNOGRM.CSV"; // if file name isn't stamped with month and date, use file name for single night
        program_state = load_data_from_files_program_state; // if file name doesn't have month and date, update program state to move on
      } // end of if key check
      
      break; // break out of selection process otherwise command under next case will execute    
      
    case prompt_user_for_month_of_file_name_program_state:
      
      if (user_entering_month_of_file_name_digit_1_program_flag == false) { // if tens place of month has not been set yet
        if ((key == '0')||(key == '1')) { // 0X or 1X valid input
          EEGDataFileNameArray[month_tens_place_file_name_element_number] = key; // update file name
          HypnogramFileNameArray[month_tens_place_file_name_element_number] = key; // update file name
          file_name_month = 10 * (key - ascii_offset); // remove ascii offset and weigh by 10^1
          user_entering_month_of_file_name_digit_1_program_flag = true; // set program flag to keep from overwriting
        } // end of if key check
        
        break; // break out of selection process otherwise command under next case will execute    
               // must break here to prevent ones digit from being set to what was entered for the tens digit value of the month!
      } // end if
    
      if (user_entering_month_of_file_name_digit_1_program_flag == true) { // if tens place of month has been set yet
        if ((key == '0')||(key == '1')||(key == '2')||(key == '3')||(key == '4')||(key == '5')||(key == '6')||(key == '7')||(key == '8')||(key == '9')) { // if user input is valid. Prompt will remain displayed until valid user input entered
          EEGDataFileNameArray[month_ones_place_file_name_element_number] = key; // update file name
          HypnogramFileNameArray[month_ones_place_file_name_element_number] = key; // update file name
          file_name_month = file_name_month + (key - ascii_offset); // remove ascii offset and add to tens value
          program_state = confirm_month_of_file_name_program_state; // update program state to move on
        } // end of if key check
      } // end if
    
      break; // break out of selection process otherwise command under next case will execute    
    
    case confirm_month_of_file_name_program_state:
    
      if ((key == 'y')||(key == 'Y')) { // if user input is valid. Prompt will remain displayed until valid user input entered. Accept upper and lower case. 
        program_state = prompt_user_for_date_of_file_name_program_state; // update program state to move on
      } // end of if key check
      
      else if ((key == 'n')||(key == 'N')) { // if user input is valid. Prompt will remain displayed until valid user input entered. Accept upper and lower case.
        user_entering_month_of_file_name_digit_1_program_flag = false; // must reset flag
        program_state = prompt_user_for_month_of_file_name_program_state; // update program state to move on
      } // end of if key check
      
      break; // break out of selection process otherwise command under next case will execute    
      
    case prompt_user_for_date_of_file_name_program_state:
      
      if (user_entering_date_of_file_name_digit_1_program_flag == false) { // if tens place of date has not been set yet
        if ((key == '0')||(key == '1')||(key == '2')||(key == '3')) { // 0X, 1X, 2X, 3X valid input
          EEGDataFileNameArray[date_tens_place_file_name_element_number] = key; // update file name
          HypnogramFileNameArray[date_tens_place_file_name_element_number] = key; // update file name
          file_name_date = 10 * (key - ascii_offset); // remove ascii offset and weigh by 10^1
          user_entering_date_of_file_name_digit_1_program_flag = true; // set program flag to keep from overwriting
        } // end of if key check
       
        break; // break out of selection process otherwise command under next case will execute  
               // must break here to prevent ones digit from being set to what was entered for the tens digit value of the month!
      } // end if
    
      if (user_entering_date_of_file_name_digit_1_program_flag == true) { // if tens place of date has been set yet
        if ((key == '0')||(key == '1')||(key == '2')||(key == '3')||(key == '4')||(key == '5')||(key == '6')||(key == '7')||(key == '8')||(key == '9')) { // if user input is valid. Prompt will remain displayed until valid user input entered
          EEGDataFileNameArray[date_ones_place_file_name_element_number] = key; // update file name
          HypnogramFileNameArray[date_ones_place_file_name_element_number] = key; // update file name
          file_name_date = file_name_date + (key - ascii_offset); // remove ascii offset and add to tens value
          program_state = confirm_date_of_file_name_program_state; // update program state to move on
        } // end of if key check
      } // end if
    
      break; // break out of selection process otherwise command under next case will execute    
    
    case confirm_date_of_file_name_program_state: 
      
      if ((key == 'y')||(key == 'Y')) { // if user input is valid. Prompt will remain displayed until valid user input entered. Accept upper and lower case. 
        eeg_file_name = new String(EEGDataFileNameArray); // generate name of file to load
        hypnogram_file_name = new String(HypnogramFileNameArray); // generate name of file to load
        program_state = load_data_from_files_program_state; // update program state to move on
      } // end of if key check
      
      else if ((key == 'n')||(key == 'N')) { // if user input is valid. Prompt will remain displayed until valid user input entered. Accept upper and lower case.
        user_entering_date_of_file_name_digit_1_program_flag = false; // must reset flag
        program_state = prompt_user_for_date_of_file_name_program_state; // update program state to move on
      } // end of if key check
      
      break; // break out of selection process otherwise command under next case will execute    
      
    case load_data_from_files_program_state:
    
      if (key == ENTER) { // enter to proceed
        user_entering_month_of_file_name_digit_1_program_flag = false; // must reset flag
        user_entering_date_of_file_name_digit_1_program_flag = false; // must reset flag
        program_state = prompt_user_to_continue_or_exit_program_state;
      } // end of if key check
      
      break;
 
    case prompt_user_for_desired_data_resolution_program_state:
    
      if ((key == 'a')||(key == 'b')||(key == 'c')||(key == 'd')||(key == 'e')||(key == 'f')) { // if user input is valid. Prompt will remain displayed until valid user input entered.
        switch (key) {
          case 'a':
            minutes_of_data_to_display = 3; // 3 min of data 
            break; // break out of selection process otherwise command under next case will execute    
          case 'b':
            minutes_of_data_to_display = 5; // 5 min of data
            break; // break out of selection process otherwise command under next case will execute    
          case 'c':
            minutes_of_data_to_display = 10; // 10 min of data
            break; // break out of selection process otherwise command under next case will execute    
          case 'd':
            minutes_of_data_to_display = 15; // 15 min of data
            break; // break out of selection process otherwise command under next case will execute    
          case 'e':
            minutes_of_data_to_display = 30; // 30 min of data
            break; // break out of selection process otherwise command under next case will execute    
          case 'f':
            minutes_of_data_to_display = 60; // 60 min of data
            break; // break out of selection process otherwise command under next case will execute    
        } // end of switch
        
        number_of_sleep_stages_to_display = minutes_of_data_to_display * 2; // sleep stage determination made every 30 sec
        number_of_eeg_data_points_to_display = minutes_of_data_to_display * number_seconds_in_a_minute; // 1 eeg datum / sec
        
        if (hypnogram_data_array_pointer_start + number_of_sleep_stages_to_display >= hypnogram_file_data_array_aligned_size) {
          hypnogram_data_array_pointer_end = (hypnogram_file_data_array_aligned_size - 1); // check / precaution
          eeg_data_array_pointer_end = maximum_guaranteed_eeg_data_array_pointer;
        } // end if
        
        else {
          hypnogram_data_array_pointer_end = hypnogram_data_array_pointer_start + number_of_sleep_stages_to_display;
          eeg_data_array_pointer_end = eeg_data_array_pointer_start + number_of_eeg_data_points_to_display;
        } // end else  
        
        program_state = viewing_data_program_state; // update program state to move on
      } // end of if key check
       
      break; // break out of selection process otherwise command under next case will execute    
       
    case viewing_data_program_state:
     
      if (key == ESC) {
        
        exit(); // end program
        
      } // end of if key check
       
      break; // break out of selection process otherwise command under next case will execute    
       
  } // end of switch
  
  return;
  
} // end of keyReleased function

// *****************************************************************************************************************************************************************************************

void mouseReleased() {
  
  if ((mouseX >= screen.width - 50) && (mouseX < screen.width) && (mouseY >= screen.height - 50) && (mouseY <= screen.height)) { // if cursor is over the exit icon, exit program
 
    exit(); // exit program
      
  } // end of if cursor position check
  
  else if ((mouseX >= screen.width - 100) && (mouseX < screen.width - 50) && (mouseY >= screen.height - 50) && (mouseY <= screen.height)) { // if cursor is over the main icon, return to main menu
    
    user_entering_month_of_file_name_digit_1_program_flag = false; // must reset program flag
    user_entering_date_of_file_name_digit_1_program_flag = false; // must reset program flag
    found_least_common_time_stamp_program_flag = false; // must reset program flag
    
    icon_eeg_display_toggle_state_delta = true; // must reset program flag
    icon_eeg_display_toggle_state_theta = true; // must reset program flag
    icon_eeg_display_toggle_state_alpha = true; // must reset program flag
    icon_eeg_display_toggle_state_beta_13_to_18 = true; // must reset program flag
    icon_eeg_display_toggle_state_beta_18_to_21 = true; // must reset program flag
    icon_eeg_display_toggle_state_beta_sleep_spindles = true; // must reset program flag
    icon_eeg_display_toggle_state_gamma = true; // must reset program flag
    
    eeg_data_array_pointer = 0; // must reset to zero (must start at 0 for finding least common time stamp)
    hypnogram_data_array_pointer = 0; // must reset to zero (must start at 0 for finding least common time stamp)
    
    eeg_data_array_pointer_start = 0; // must reset to zero
    eeg_data_array_pointer_end = 0; // must reset to zero

    hypnogram_data_array_pointer_start = 0; // must reset to zero 
    hypnogram_data_array_pointer_end = 0; // must reset to zero

    program_state = prompt_user_to_continue_or_exit_program_state;
      
  } // end of if cursor position check

    else if ((mouseX >= screen.width - 150) && (mouseX < screen.width - 100) && (mouseY >= screen.height - 50) && (mouseY <= screen.height)) { // if cursor is over the third icon, third icon = take a screen shot
      
      Date now = new Date();
      fileName = fnameFormat.format(now); // update the date and time for file stamping
      saveFrame("zeo_data_visualization_program_screenshot_" + fileName + ".jpeg"); // save image as jpeg file.
    
    } // end of if cursor position check  
  
  if (program_state == viewing_data_program_state) { // only take action if viewing data, ignore mouse clicks during prompts / user input process
       
    if ((mouseX >= screen.width - 100) && (mouseX < screen.width - 50) && (mouseY >= screen.height / 2 - 25) && (mouseY <= screen.height / 2 + 25)) { // if cursor is over the first icon, first icon = previous so go back
    
      if (hypnogram_data_array_pointer_start - number_of_sleep_stages_to_display >= 0) {
        
        hypnogram_data_array_pointer_end = hypnogram_data_array_pointer_start;
        hypnogram_data_array_pointer_start = hypnogram_data_array_pointer_end - number_of_sleep_stages_to_display;
        
        eeg_data_array_pointer_end = eeg_data_array_pointer_start;
        eeg_data_array_pointer_start = eeg_data_array_pointer_end - number_of_eeg_data_points_to_display;
        
      } // end if
      
      else {
        
        if (hypnogram_data_array_pointer_start != 0) { // else do nothing if at beginning of data
          
          hypnogram_data_array_pointer_end = hypnogram_data_array_pointer_start;
          hypnogram_data_array_pointer_start = 0;
        
          eeg_data_array_pointer_end = eeg_data_array_pointer_start;
          eeg_data_array_pointer_start = 0;
          
        } // end if
        
      } // end else
        
    } // end of if cursor position check

    else if ((mouseX >= screen.width - 50) && (mouseX < screen.width) && (mouseY >= screen.height / 2 - 25) && (mouseY <= screen.height / 2 + 25)) { // if cursor is over the second icon, second icon = next so go forward
       
      if (hypnogram_data_array_pointer_end + number_of_sleep_stages_to_display < hypnogram_file_data_array_aligned_size) {
        
        hypnogram_data_array_pointer_start = hypnogram_data_array_pointer_end;
        hypnogram_data_array_pointer_end = hypnogram_data_array_pointer_start + number_of_sleep_stages_to_display;
        
        eeg_data_array_pointer_start = eeg_data_array_pointer_end;
        eeg_data_array_pointer_end = eeg_data_array_pointer_start + number_of_eeg_data_points_to_display;
        
      } // end if
      
      else {
        
        if (hypnogram_data_array_pointer_end != (hypnogram_file_data_array_aligned_size - 1)) { // else do nothing if at end of data
          
          hypnogram_data_array_pointer_start = hypnogram_data_array_pointer_end;
          hypnogram_data_array_pointer_end = hypnogram_file_data_array_aligned_size - 1;
        
          eeg_data_array_pointer_start = eeg_data_array_pointer_end;
          eeg_data_array_pointer_end  = maximum_guaranteed_eeg_data_array_pointer;

        } // end if
        
      } // end else
   
    } // end of if cursor position check
    
    else if ((mouseX >= (legend_toggle_icon_x - legend_toggle_icon_width / 2)) && (mouseX <= (legend_toggle_icon_x + legend_toggle_icon_width / 2)) && (mouseY >= (display_key_y - legend_toggle_icon_height / 2)) && (mouseY <= (display_key_y + legend_toggle_icon_height / 2))) { 
      icon_eeg_display_toggle_state_delta = !icon_eeg_display_toggle_state_delta; // toggle state from true to false or from false to true   
    } // end of if cursor position check
    
    else if ((mouseX >= (legend_toggle_icon_x - legend_toggle_icon_width / 2)) && (mouseX <= (legend_toggle_icon_x + legend_toggle_icon_width / 2)) && (mouseY >= ((display_key_y + display_key_y_offset) - legend_toggle_icon_height / 2)) && (mouseY <= ((display_key_y + display_key_y_offset) + legend_toggle_icon_height / 2))) { 
      icon_eeg_display_toggle_state_theta = !icon_eeg_display_toggle_state_theta; // toggle state from true to false or from false to true
    } // end of if cursor position check
    
    else if ((mouseX >= (legend_toggle_icon_x - legend_toggle_icon_width / 2)) && (mouseX <= (legend_toggle_icon_x + legend_toggle_icon_width / 2)) && (mouseY >= ((display_key_y + 2 * display_key_y_offset) - legend_toggle_icon_height / 2)) && (mouseY <= ((display_key_y + 2 * display_key_y_offset) + legend_toggle_icon_height / 2))) { 
      icon_eeg_display_toggle_state_alpha = !icon_eeg_display_toggle_state_alpha; // toggle state from true to false or from false to true
    } // end of if cursor position check
    
    else if ((mouseX >= (legend_toggle_icon_x - legend_toggle_icon_width / 2)) && (mouseX <= (legend_toggle_icon_x + legend_toggle_icon_width / 2)) && (mouseY >= ((display_key_y + 3 * display_key_y_offset) - legend_toggle_icon_height / 2)) && (mouseY <= ((display_key_y + 3 * display_key_y_offset) + legend_toggle_icon_height / 2))) { 
      icon_eeg_display_toggle_state_beta_13_to_18 = !icon_eeg_display_toggle_state_beta_13_to_18; // toggle state from true to false or from false to true
    } // end of if cursor position check
    
    else if ((mouseX >= (legend_toggle_icon_x - legend_toggle_icon_width / 2)) && (mouseX <= (legend_toggle_icon_x + legend_toggle_icon_width / 2)) && (mouseY >= ((display_key_y + 4 * display_key_y_offset) - legend_toggle_icon_height / 2)) && (mouseY <= ((display_key_y + 4 * display_key_y_offset) + legend_toggle_icon_height / 2))) { 
      icon_eeg_display_toggle_state_beta_18_to_21 = !icon_eeg_display_toggle_state_beta_18_to_21; // toggle state from true to false or from false to true
    } // end of if cursor position check
    
    else if ((mouseX >= (legend_toggle_icon_x - legend_toggle_icon_width / 2)) && (mouseX <= (legend_toggle_icon_x + legend_toggle_icon_width / 2)) && (mouseY >= ((display_key_y + 5 * display_key_y_offset) - legend_toggle_icon_height / 2)) && (mouseY <= ((display_key_y + 5 * display_key_y_offset) + legend_toggle_icon_height / 2))) { 
      icon_eeg_display_toggle_state_beta_sleep_spindles = !icon_eeg_display_toggle_state_beta_sleep_spindles; // toggle state from true to false or from false to true
    } // end of if cursor position check
    
    else if ((mouseX >= (legend_toggle_icon_x - legend_toggle_icon_width / 2)) && (mouseX <= (legend_toggle_icon_x + legend_toggle_icon_width / 2)) && (mouseY >= ((display_key_y + 7 * display_key_y_offset) - legend_toggle_icon_height / 2)) && (mouseY <= ((display_key_y + 7 * display_key_y_offset) + legend_toggle_icon_height / 2))) { 
      icon_eeg_display_toggle_state_gamma = !icon_eeg_display_toggle_state_gamma; // toggle state from true to false or from false to true
    } // end of if cursor position check
   
  } // end if 
 
  return;
 
} // end of mouseReleased function

// *****************************************************************************************************************************************************************************************
