# new IDEx processing linking all outputs by letter and filling in missing NHS numbers by different field matching 
# to be used for the File_1 creation from the ExECT Z drive output

library(readr)
library(dplyr)
# library(zoo) #for dates = but experimented here with origin
library(lubridate)
library(readxl)

options(scipen = 999) #numbers should not be displayed in scientific notation
options(digits = 6) #Number of digits to be displayed

setwd("C:/Users/Beata/Documents/Epi25letters/IDExOutput/File_1_test")# set working dir

# 1 total number of people in the cohort----


# 1a Surname ----


Surname <- read.csv(file = "SURNAME.csv", sep = ",", na = c("","NA","null", "NULL"), header = FALSE) # may need to add sep ":" as sometimes if file was opened in excel it gets ':' as separators

# Adding headers, we may also need to concatenate clinic date, letter date, and DoB - later!

colnames(Surname) <- c("Letter","Start","End","Surname", "Rule")

Surname$Surname <- tolower(Surname$Surname) # as surname may be written in allCAPS need to convert to lower or could convert to CAPS

head(Surname)

# 1b Name ----

Name <- read.csv(file = "FORENAME.csv", sep = ",", na = c("","NA","null", "NULL"), header = FALSE) # may need to add sep ":" as sometimes if file was opened in excel it gets ':' as separators

# Adding headers, we may also need to concatenate clinic date, letter date, and DoB - later!

colnames(Name) <- c("Letter","Start","End","FirstName", "MiddleName" , "Rule")

Name$FirstName <- tolower(Name$FirstName) # converting to the same case, here to lower


head(Name)

# 1c Address ----

Address <- read.csv(file = "ADDRESS_1.csv", sep = ",", na = c("","NA","null", "NULL"), header = FALSE) # may need to add sep ":" as sometimes if file was opened in excel it gets ':' as separators

# Adding headers, we may also need to concatenate clinic date, letter date, and DoB - later!

colnames(Address) <- c("Letter","Start","End","Address", "Rule")

head(Address)

# 1d PostCode ----

PC <- read.csv(file = "POSTCODE.csv", sep = ",", na = c("","NA","null", "NULL"), header = FALSE) # may need to add sep ":" as sometimes if file was opened in excel it gets ':' as separators

# Adding headers, we may also need to concatenate clinic date, letter date, and DoB - later!

colnames(PC) <- c("Letter","Start","End","PC", "Rule")

head(PC)

# 1e NHS----

NHS <- read.csv(file = "NHS.csv", sep = ",", na = c("","NA","null", "NULL"), header = FALSE) # may need to add sep ":" as sometimes if file was opened in excel it gets ':' as separators

# Adding headers, we may also need to concatenate clinic date, letter date, and DoB - later!

colnames(NHS) <- c("Letter","Start","End","NHS", "Rule")

head(NHS)

# 1f NHS----

DoB <- read.csv(file = "DateofBirth.csv", sep = ",", na = c("","NA","null", "NULL"), header = FALSE) # may need to add sep ":" as sometimes if file was opened in excel it gets ':' as separators

# Adding headers, we may also need to concatenate clinic date, letter date, and DoB - later!

colnames(DoB) <- c("Letter","Start","End","DoB", "Rule")

head(DoB)


Gender <- read.csv(file = "Gender.csv", sep = ",", na = c("","NA","null", "NULL"), header = FALSE) # may need to add sep ":" as sometimes if file was opened in excel it gets ':' as separators

# Adding headers, we may also need to concatenate clinic date, letter date, and DoB - later!

colnames(Gender) <- c("Letter","Start","End","Gender", "Rule")

str(Gender)

Gender$Gender <- tolower(Gender$Gender)

HospNo <- read.csv(file = "HospNumber.csv", sep = ",", na = c("","NA","null", "NULL"), header = FALSE) # may need to add sep ":" as sometimes if file was opened in excel it gets ':' as separators

# Adding headers, we may also need to concatenate clinic date, letter date, and DoB - later!

colnames(HospNo) <- c("Letter","Start","End","HospNo", "Rule")




# 1f Joining by letter

Surname1 <- Surname %>% 
  select(Letter, Surname)

Name1 <- Name %>% 
  select(Letter, FirstName, MiddleName)

Address1 <- Address %>% 
  select(Letter, Address)

NHS1 <- NHS %>% 
  select(Letter, NHS)

PC1 <- PC %>% 
  select(Letter, PC)

DoB1 <- DoB %>% 
  select(Letter, DoB)

Gender1 <- Gender %>% 
  select(Letter, Gender)

HospNo1 <- HospNo %>% 
  select(Letter, HospNo)


Persons <- full_join(Name1, Surname1) %>% 
  full_join(Address1) %>% 
  full_join(PC1) %>% 
  full_join(NHS1) %>% 
  full_join(DoB1) %>% 
  full_join(HospNo1) %>% 
  full_join(Gender1) %>% 
  distinct()

str(Persons)


Persons$NHS<-gsub(" ","", as.character(Persons$NHS))
Persons$NHS<-gsub("-","", as.character(Persons$NHS))
Persons$PC<-gsub(" ","", as.character(Persons$PC))

## Number of lettrs without an NHS number 

MissingNHS <- Persons %>% 
  filter(is.na(NHS)) %>% 
count() 



head(MissingNHS) # 120 out of  ~ 770
proportionMissing <- (120*100)/770  # ~ 15% of letters missing NHS number


# filling in the missing NHS Numbers by matching with letters that do have them i.e. finding out the individuals who match

# 1st  Matching on DoB, PostCode, First name, Surname, and gender

Indiv <- Persons %>%  
  select(DoB, PC, FirstName, Surname, Gender, NHS) %>% 
  filter(!is.na(NHS), !is.na(PC)) %>% 
  distinct() 

#View(Indiv)

Indiv <- Indiv %>% 
  rename(NHS1 = NHS) # renaming NHS to NHS1 in Indiv so that a new column can be created after left-joining the tables


LetterSetNHS <- left_join(Persons, Indiv, by=c('PC' = 'PC', 'FirstName' = 'FirstName','Surname' = 'Surname', 'DoB' = 'DoB', 'Gender' = 'Gender') ) 
 
 # numbers missing after matching 
MissingNHS1 <- LetterSetNHS %>% 
  filter(is.na(NHS1)) %>% 
  count()      # 50 out of ~ 770, so 70 out of the original 120 missing where now assigned the NHS number 

# head(MissingNHS1)

proportionMissing <- (50*100)/770   # ~ 6% of letters missing NHS number after matching for Post code, DoB, Name, Surname, Gender


# 2nd line of matching to get missing NHS Number: Hospital number, Gender, DoB, FirstName, Surname - we should capture those that moved
 
 
 Indiv2 <- Persons %>% 
   select(DoB, HospNo, FirstName, Surname, Gender, NHS) %>% 
   filter(!is.na(NHS), !is.na(HospNo)) %>% 
   distinct() %>% 
   rename(NHS2 = NHS) # renaming NHS to NHS2 will create a third NHS column after linking


  LetterSetNHS2 <- left_join(LetterSetNHS, Indiv2, by=c('FirstName' = 'FirstName','Surname' = 'Surname', 'DoB' = 'DoB', 'Gender' = 'Gender', "HospNo" = "HospNo") )
 
 View(LetterSetNHS2) 
  
  # letters that have no NHS number after the second or third match
 
 MissingNHS1and2 <- LetterSetNHS2 %>% 
   filter(is.na(NHS1) & is.na(NHS2)) %>%  
   count()      # 20 letters still missing the NHS number after matching by First name, surname, DoB, Gender, and Hospital number 
 
head(MissingNHS1and2) 
proportionMissing <- (20*100)/770   # ~ 2.5 % letters missing NHS No after further matching as above
 
 

##  3rd match on DoB, First Name, Surname,  PostCode  - this will get those with missing hospital numbers

Indiv3 <- Persons %>% 
  select(DoB, FirstName, Surname, PC, NHS) %>% 
  filter(!is.na(NHS)) %>%  
  distinct() %>%  
  rename(NHS3 = NHS)

str(Indiv3)

LetterSetNHS3 <- left_join(LetterSetNHS2, Indiv3, by=c('FirstName' = 'FirstName','Surname' = 'Surname', 'PC' = 'PC', 'DoB') ) 

View(LetterSetNHS3)

MissingNHS1and2and3 <- LetterSetNHS3 %>% 
  filter(is.na(NHS1) & is.na(NHS2) & is.na(NHS3)) %>%  
  count()      # 17 letters still missing the NHS number after matching by First name, surname,post code, and DoB



head(MissingNHS1and2and3) 
proportionMissing <- (17*100)/770   # ~ 2% letters missing NHS No after further matching for 
head(proportionMissing)



## 4th matching on name, surname, DoB, and gender - wen postcode and hospital number are missing
 
 Indiv4 <- Persons %>% 
  select(DoB, FirstName, Surname, Gender, NHS) %>% 
   filter(!is.na(NHS)) %>%  
   distinct() %>%  
   rename(NHS4 = NHS)
 
 #View(Indiv4)
 
 LetterSetNHS4 <- left_join(LetterSetNHS3, Indiv4, by=c('FirstName' = 'FirstName','Surname' = 'Surname', 'DoB' = 'DoB', 'Gender' = 'Gender') ) 
 
 View(LetterSetNHS4)
 
 MissingNHS1and2and3and4 <- LetterSetNHS4 %>% 
   filter(is.na(NHS1) & is.na(NHS2) & is.na(NHS3) & is.na(NHS4)) %>%  
   count()      # 8 letters still missing the NHS number after matching by First name, surname, DoB, 
 
 head(MissingNHS1and2and3and4) 
 proportionMissing <- (8*100)/770   # ~ 1% letters missing NHS No after further matching for 
 head(proportionMissing)
 

 
  
 # Final NHS number based on the different matches above - creating a single column
 
 AssignedNHS <- LetterSetNHS4 %>% 
   mutate(NHS_No = case_when(!is.na(NHS) ~ NHS,
                             is.na(NHS) & !is.na(NHS1) ~ NHS1,
                             is.na(NHS) & is.na(NHS1) & !is.na(NHS2) ~ NHS2, 
                             is.na(NHS) & is.na(NHS1) & is.na(NHS2) & !is.na(NHS3)~ NHS3, 
                             is.na(NHS) & is.na(NHS1) & is.na(NHS2) & is.na(NHS3) & !is.na(NHS4)~ NHS4), .after = "NHS4")
 

AssignedNHS <- AssignedNHS %>% 
  select(- "NHS", - "NHS1", - "NHS2", - "NHS3", - "NHS4") %>% 
  distinct()
 
# checking the final number of letters with mising NHS numbers  - it should be the same as MissingNHS1and2and3and4
  
NHSLetterCount <- AssignedNHS %>% 
  filter(is.na(NHS_No)) %>% 
  count() # 8 so ~ 1% of the whole set, same records as in MissingNHS1and2and3and4
  

 
 
 
