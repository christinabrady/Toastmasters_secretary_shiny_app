library(RODBC)
tm <- odbcConnect("")

meetings <- read.csv("~/docs/manual_work.csv")

meetings$meeting_date <- as.Date(meetings$meeting_date, "%m/%d/%y")
head(meetings)

### fix the discrepancy in how I am treating role names in the db:
meetings$role <- gsub(" ", "_", meetings$role)
meetings$role[meetings$role == "timer/vote_counter"] <- "timer_and_voter_counter"


sqlSave(tm, meetings, 'meetings', varTypes = c(meeting_date = "date", role = "varchar", name = "varchar"), colnames = FALSE, rownames = FALSE)

sqlSave(tm, mem, 'members', varTypes = c(name = "varchar", member_since = "date", status = "varchar"), colnames = FALSE, rowname = FALSE)

### change award date to meeting_date

awards <- read.csv("~/docs/manual_awards.csv")

awards$meeting_date <- as.Date(awards$meeting_date, "%m/%d/%y")
sqlSave(tm, awards, 'awards', varTypes = c(award = "varchar", name = "varchar", meeting_date = "date"), colnames = FALSE, rowname = FALSE)