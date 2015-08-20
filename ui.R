library(shiny)
library(shinydashboard)

source("./global.R")

shinyUI(dashboardPage(skin = "blue",
	dashboardHeader(title = "Challenger TM"),
	dashboardSidebar(
		sidebarMenu(
			menuItem("Record Attendence", tabName = "datain"), 
			menuItem("Print Report", tabName = "dataout")
		)
	),
	dashboardBody(
			tabItems(
				tabItem("datain", 
					fluidRow(
						column(width = 4,
							
							box(width = NULL, 
								dateInput("meeting_date", label = "Date of Meeting")
								),

							box(
								title = "Awards", width = NULL, 
								selectInput("bs", awards_list[1], active_member_list), 
								selectInput("be", awards_list[2], active_member_list), 
								selectInput("btt", awards_list[3], active_member_list)
							),
							
							box(width = NULL, 
								title = "Support Roles", 
								selectInput(roles_list[1], field_names[1], active_member_list),
								selectInput(roles_list[2], field_names[2], active_member_list),
								selectInput(roles_list[3], field_names[3], active_member_list), 
								selectInput(roles_list[4], field_names[4], active_member_list), 
								selectInput(roles_list[5], field_names[5], active_member_list), 
								selectInput(roles_list[17], field_names[17], active_member_list)
								)
						),

						column(width = 4, 
							box(width = NULL, 
								title = "Speakers",
								"After selecing the speakers, please type the speech number and speech title in the format: number, title (i.e. 1, Not all those who wander are lost). If the speech is from an advanced manual, please include an 'A' before the number (i.e. A1).", 
								selectInput(roles_list[7], field_names[7], active_member_list), 
								textInput("s1_dat", "Speaker 1's speech number and title"),
								selectInput(roles_list[8], field_names[8], active_member_list),
								textInput("s2_dat", "Speaker 2's speech number and title"),
								selectInput(roles_list[9], field_names[9], active_member_list), 
								textInput("s3_dat", "Speaker 3's speech number and title"),
								selectInput(roles_list[10], field_names[10], active_member_list),
								textInput("s4_dat", "Speaker 4's speech number and title"),
								selectInput(roles_list[11], field_names[11], active_member_list),
								textInput("s5_dat", "Speaker 5's speech number and title")
								)

						),
						
						column(width = 4, 
							
							box(width = NULL, 
								title = "Evaluators", 
								selectInput(roles_list[6], field_names[6], active_member_list), 
								selectInput(roles_list[12], field_names[12], active_member_list),
								selectInput(roles_list[13], field_names[13], active_member_list),
								selectInput(roles_list[14], field_names[14], active_member_list),
								selectInput(roles_list[15], field_names[15], active_member_list),
								selectInput(roles_list[16], field_names[16], active_member_list)
								),

							box(width = NULL, 
								selectInput(roles_list[18], field_names[18], active_member_list),
								selectInput(roles_list[19], field_names[19], active_member_list),
								selectInput(roles_list[20], field_names[20], active_member_list),
								selectInput(roles_list[21], field_names[21], active_member_list),
								selectInput(roles_list[22], field_names[22], active_member_list), 
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
							dateInput("report_for", label = meetings_to_date),
							actionButton("sec_report", label = "Export Secretary's Report") 
						)
					)
				)
			)
		)
))