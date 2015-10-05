# setwd("~/Documents/Toastmasters/secretary_shiny_app")
options(stringsAsFactors = FALSE)
library(shiny)
library(RODBC)
library(ggvis)
library(xtable)

source("./include/db_connection.R")
source("./include/usr_pswd.R")

roster <- sqlQuery(tm, "SELECT name FROM members WHERE status = 'Active'")

active_member_list <- c(roster$name)

field_names <- c("Toastmaster", 
				"Thought of the Day", 
				"Ah Counter",
				"Grammarian", 
				"Timer/Vote Counter",
				"General Evaluator",
				"Table Topics Master",  
				"Speaker", 
				"Evaluator",	
				"Attendee",
				"Contest Chair", 
				"Contest Judge")

roles_list <- tolower(gsub(" ", "_", field_names))

names(field_names) <- roles_list

awards_list <- c("Best Speaker", 
				"Best Evaluator", 
				"Best Table Topics Response"
				)

meetings_to_date <- sqlQuery(tm, "SELECT DISTINCT meeting_date FROM meetings")
meetings_to_date <- rbind(as.character(as.Date(Sys.time())), meetings_to_date)  ### add current date to the list because I'm too lazy to make the UI responsive. 
meetings_to_date$ui_format <- format(as.Date(meetings_to_date$meeting_date), "%B %d, %Y")

memdb <- sqlQuery(tm, "SELECT name FROM members")

### data prep:

active_members <- as.character(sqlQuery(tm, "SELECT COUNT(*) FROM members WHERE status = 'Active'"))

## monthly attendance:
monthly_attend_prep <- function(){
	allmeet  <- sqlQuery(tm, "SELECT * FROM meetings")
	allmeet$member <- ifelse(allmeet$name != 'guest', "Members", "Guests")
	meet_tots <- as.data.frame(with(allmeet, table(meeting_date)))
	meet_tots$member <- "Total"
	mem_non <- rbind(meet_tots, as.data.frame(with(allmeet, table(meeting_date, member))))
	mem_non <- subset(mem_non, meeting_date != "meeting_date") ## silly mistake pushing to the database
	mem_non$date_long <- as.character(format(as.Date(mem_non$meeting_date), "%B %d, %Y"))
	mem_non$date_long <- factor(mem_non$date_long, levels = unique(mem_non$date_long))
	return(mem_non)
}

monthly_new_mem_data_prep <- function(){
	allmeet  <- sqlQuery(tm, "SELECT * FROM meetings")
	### new members per month
	mem_split <- split(subset(allmeet, select = c("name", "meeting_date")), allmeet$name)
	first_meet <- lapply(mem_split, function(x){
		x <- x[order(x$meeting_date), ]
		return(head(x, 1))
		})
	first_meetdf <- do.call(rbind, first_meet)
	first_meetdf$meeting_dateMY <- format(as.Date(first_meetdf$meeting_date), "%B %Y")
	monthly_new_mem <- as.data.frame(with(first_meetdf, table(meeting_dateMY)), stringsAsFactors = FALSE)


	### take out July and August 2014 because I only have data since July 2014 so all current members at that time have a first meeting date of July or August 2014
	monthly_new_mem <- monthly_new_mem[!(monthly_new_mem$meeting_dateMY %in% c("July 2014", "August 2014")),]
	monthly_new_mem$order_var <- as.Date(paste("01", monthly_new_mem$meeting_dateMY), "%d %B %Y")
	monthly_new_mem$meeting_dateMY <- factor(monthly_new_mem$meeting_dateMY, levels = monthly_new_mem$meeting_dateMY[order(monthly_new_mem$order_var)])

	### add names so that I can plot them:
	MYsplit <- split(first_meetdf, first_meetdf$meeting_dateMY)
	MYmem <- lapply(MYsplit, function(x){
		xn <- paste(x$name, collapse = ", ")
		return(xn)
		})
	MYmemdf <- stack(MYmem)
	colnames(MYmemdf) <- c("names", "meeting_dateMY")

	new_mem <- merge(monthly_new_mem, MYmemdf)
	return(new_mem)

}

replace_null <- function(x){
	if(is.list(x)){
		x <- lapply(x, function(y) replace_null(y))
		return(x)
	}
	if(is.null(x)){
		x <- " "
	}else{
		return(x)
	}
}
