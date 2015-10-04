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
					conditionalPanel( 
						condition = "!output.formSubmitted", 

						fluidRow(
							column(width = 4,
								
								box(width = NULL, title = "Meeting Date", solidHeader = TRUE, status = "primary", 
									dateInput("meeting_date", label = "")
									),
								
								box(width = NULL, solidHeader = TRUE, status = "primary",
									title = "Meeting Roles", 
									selectizeInput(roles_list[1], field_names[1], choices = NULL, options = list(create = TRUE)),
									selectizeInput(roles_list[2], field_names[2], choices = NULL, options = list(create = TRUE)),
									selectizeInput(roles_list[3], field_names[3], choices = NULL, options = list(create = TRUE)),
									selectizeInput(roles_list[4], field_names[4], choices = NULL, options = list(create = TRUE)),
									selectizeInput(roles_list[5], field_names[5], choices = NULL, options = list(create = TRUE)),
									selectizeInput(roles_list[6], field_names[6], choices = NULL, options = list(create = TRUE)),
									selectizeInput(roles_list[7], field_names[7], choices = NULL, options = list(create = TRUE))
									)
							),

							column(width = 4, 
								box(width = NULL, solidHeader = TRUE, status = "primary",
									title = "Speakers",
									selectizeInput(roles_list[8], field_names[8], choices = NULL, multiple = TRUE, options = list(create = TRUE)),
									textInput("speechesin", "What project number did each speaker complete?")
									),

								box(width = NULL, solidHeader = TRUE, status = "primary",
									title = "Evaluators", 
									selectizeInput(roles_list[9], "", choices = NULL, multiple = TRUE, options = list(create = TRUE))
									),

								box(width = NULL, solidHeader = TRUE, status = "primary",
									title = "Attendees that did not have roles:",
									selectizeInput(roles_list[10], "", choices = NULL, multiple = TRUE, options = list(create = TRUE))
									)

							),
							
							column(width = 4, 
								
								box(
									title = "Awards", width = NULL, solidHeader = TRUE, status = "primary",
									selectizeInput("bs", awards_list[1], choices = active_member_list, options = list(create = TRUE), multiple = TRUE),
									selectizeInput("be", awards_list[2], choices = active_member_list, options = list(create = TRUE), multiple = TRUE),
									selectizeInput("btt", awards_list[3], choices = active_member_list, options = list(create = TRUE), multiple = TRUE)
								),

								box(
									title = "Contests", width = NULL, solidHeader = TRUE, status = "primary",
									selectizeInput(roles_list[11], field_names[11], choices = NULL),
									selectizeInput(roles_list[12], field_names[12], choices = NULL, multiple = TRUE)
								),

								box(width = NULL, solidHeader = TRUE, status = "primary",
									title = "Guests", 
									textInput("guests", "How many guests attended? (If no guests attended, please input 0.)")
									
								),


								box(
									title = NULL, width = NULL, background = "light-blue", solidHeader = TRUE, 
									actionButton(inputId = "submitbtn", label = "Submit")
								)
							)
						)
					), 

					conditionalPanel(
						condition = "output.formSubmitted",
						h3(textOutput("TYmessage"))
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