library(shiny)
library(shinydashboard)

source("./global.R")

shinyUI(dashboardPage(skin = "blue",
	dashboardHeader(title = "Challenger TM"),
	dashboardSidebar(
		sidebarMenu(
			menuItem("Home", tabName = "viz"),
			menuItem("Record Attendence", tabName = "datain"), 
			menuItem("Attendance Report", tabName = "dataout")
		)
	),
	dashboardBody(
			tabItems(
				tabItem("viz", 
					fluidRow(
						infoBox("Active Members", active_members, fill =TRUE, color = "light-blue"),
						column(width = 10, 
							ggvisOutput('monthly_attend_vis')
							), 
						column(width = 10, 
							ggvisOutput('new_mem_vis')
							)
						)	

					),

				tabItem("datain", 
					fluidRow(
						column(width = 4,
							
							box(width = NULL, 
								dateInput("meeting_date", label = "Date of Meeting")
								),
							
							box(width = NULL, 
								title = "Meeting Roles", 
								selectizeInput(roles_list[1], field_names[1], choices = NULL),
								selectizeInput(roles_list[2], field_names[2], choices = NULL),
								selectizeInput(roles_list[3], field_names[3], choices = NULL),
								selectizeInput(roles_list[4], field_names[4], choices = NULL),
								selectizeInput(roles_list[5], field_names[5], choices = NULL),
								selectizeInput(roles_list[6], field_names[6], choices = NULL),
								selectizeInput(roles_list[7], field_names[7], choices = NULL)
								)
						),

						column(width = 4, 
							box(width = NULL, 
								title = "Speakers",
								selectizeInput(roles_list[8], field_names[8], choices = NULL, multiple = TRUE),
								textInput("speechesin", "What project number did each speaker complete?")
								),

							box(width = NULL, 
								title = "Evaluators", 
								selectizeInput(roles_list[9], field_names[9], choices = NULL, multiple = TRUE)
								),

							box(width = NULL, 
								title = "Attendees that did not have roles:",
								selectizeInput(roles_list[10], field_names[10], choices = NULL, multiple = TRUE)
								)

						),
						
						column(width = 4, 
							
							box(
								title = "Awards", width = NULL, 
								selectizeInput("bs", awards_list[1], choices = NULL),
								selectizeInput("be", awards_list[2], choices = NULL),
								selectizeInput("btt", awards_list[3], choices = NULL)
							),

							box(width = NULL, 
								title = "Guests", 
								textInput("guests", "How many guests attended?")
							),


							box(
								title = NULL, width = NULL, background = "blue", 
								actionButton(inputId = "submitbtn", label = "Submit")
							)
						)
					)
				),

				tabItem("dataout",
					fluidRow(
						box(
							title = NULL, width = 4, status = "primary", background = "light-blue",
							selectInput("report_for", "Meeting Date", rev(meetings_to_date$ui_format[order(as.Date(meetings_to_date$meeting_date))]))
						)
					),

					fluidRow( 
						box(width = 6, 
							textOutput("choose_meet_message"),
							tableOutput("sec_report")
						) 
					)
				)
			)
		)
	
	)
)