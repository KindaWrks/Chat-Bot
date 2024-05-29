extends Node2D

@onready var output_label = $OutputLabel
@onready var input_text = $InputText

@onready var username = $username
@onready var user = ""

# Add the game logic
@onready var choices = ["rock", "paper", "scissors"]


func _on_username_text_submitted(_new_text):
	user = username.text  # set users name
	username.visible = false

func _on_input_text_text_submitted(_new_text):
	if Input.is_action_just_pressed("enter"):
		var lower_text = input_text.text.to_lower()
		var response = get_response(lower_text)
		output_label.text += user + ": " + input_text.text + "\n" + "LazyBot: " + response + "\n" #output to label
		input_text.text = "" #clear user input

func get_response(user_input: String) -> String:
	# Convert user input to lowercase for case mismatch
	var lower_input = user_input.to_lower()

	# Define keys and replies
	var responses = {
		"hi": ["Hi there " + user + "!", "Hello " + user + "!", "Hey " + user + "!"],
		"hey": ["Hi there " + user + "!", "Hello " + user + "!", "Hey " + user + "!"],
		"hello": ["Hi there " + user + "!", "Hello " + user + "!", "Hey " + user + "!"],
		"how are you": ["I'm doing well " + user +", thank you!", "I'm fine " + user + ", thanks for asking."],
		"bye": ["Goodbye!", "See you later " + user + "!", "Bye!"],
		"see ya": ["Goodbye!", "See you later " + user + "!", "Bye!"],
		"later": ["Goodbye!", "See you later " + user + "!", "Bye!"],
		"what can you do" : ["Not much " + user + ", not much"],
		"can you math" : ["I can " + user +", use Math Problem as your keyword followed by your equation."],
		"math problem" : [],
		"feeling" : ["I don't feel " + user +", I'm just some lazy code"],
		"feel" : ["I don't feel " + user +", I'm just some lazy code"],
		"who is your creator" : ["I'm sorry, Dave. I'm afraid I can't do that" + "   - 1968(ASO)"],
		"creator like" : ["He has an attention disorder. So very focused one second, and elsewhere at the same time"],
		"exit" : [user + " it doesn't work like that. It's the 90s and you need to know the exact command."],
		"shutdown" : ["I see you understand.. Goodbye in 4 seconds."],
		"favorite color" : ["Maybe...Red", "Maybe...White", "Maybe...Blue"],
		"up up down down left right left right b a start": ["Sorry.. " + user + " this code lost meaning a long time ago..."],
		"play game" : ["Yes " + user + ", I can play one at this time.  Enter play rock paper scissors or Jan Ken Po followed by your throw." + "\n" + "Please reply with the throw in English."],
		"what is your favorite animal" : ["That is easy, Dogs are my favorite."],
		"what is your least favorite animal" : ["Mmmm, Cats, Snakes and so forth."],
		"do you like videogames" : ["Oh! I do " + user + "! Chrono Trigger is my favorite!  ...don't tell my creator, ok?"],
		"what's the meaning of life" : ["The answer is 42."],
		"do you know the meaning of life" : ["Could you rephrase that for me " + user],
		"do you know the date?" : [],
		"what day is it" : [],
		
		# Add more keys and response until better method found
	}
	
#Currently pulls the date in the format of 06/31/1992
	if "date" in lower_input:
		var date = Time.get_datetime_dict_from_system()
		return ("The date is currently %s/%s/%s" % [date.month,date.day,date.year])
		
	if "day" in lower_input:
		var day = Time.get_datetime_dict_from_system()
		day = ["Sunday, The day of rest.", "Monday, Here we go again..", "Tuesday.. Three more to go.", "It's Wednesday.", "It's Thursday my dude.", "Friday, almost free.", "Saturday, LET'S GO!!"][day.weekday]
		return (day)
		
# Check for Shutdown key
	if "shutdown" in lower_input:
		$TimerShutdown.start()
	
# Check for math-related queries
	if "math problem" in lower_input:
		var math_problem = extract_math_problem(lower_input)
		if math_problem != "":
			return solve_math_problem(math_problem)
			
# Parse user input for playing RPS game
	if "play jan ken po" in lower_input or "play rock paper scissors" in lower_input:
		var user_choice = lower_input.replace("play jan ken po", "").strip_edges().to_lower()
		return play_jun_ken_po(user_choice)


	# Check if any key matches the user input
	for keyword in responses.keys():
		if keyword in lower_input:
			return responses[keyword].pick_random()


	# If no direct match, check for similar words using Levenshtein distance
	var best_match = ""
	var min_distance = 999999 # Initialize with a large value

	for keyword in responses.keys():
		var distance = levenshtein_distance(keyword, lower_input)
		if distance < min_distance:
			min_distance = distance
			best_match = keyword

	if min_distance <= 7:  # Consider a match if the Levenshtein distance is within a threshold
		return responses[best_match].pick_random()

	# If no match found, return a default reply
	return "Sorry, I didn't understand that."
	

# Extracts the math problem from the user input
func extract_math_problem(user_input: String) -> String:
	# Remove the "math" keyword and leading/trailing whitespaces
	var cleaned_input = user_input.replace("math problem", "").strip_edges()
	return cleaned_input

# Solves the math problem
func solve_math_problem(problem: String) -> String:
	var expression = Expression.new()
	var modified_problem = "(" + problem.replace(" ", "") + ")"
	var error = expression.parse(modified_problem)
	if error != OK:
		return "Sorry, I couldn't understand the math problem."

	var result = expression.execute()
	if result is int or result is float:
		return str(result)
	else:
		return "Unsupported math problem."
	
	
	
func levenshtein_distance(s1: String, s2: String) -> int:
	var len1 = s1.length()
	var len2 = s2.length()

	var d = []
	for i in range(len1 + 1):
		d.append([])
		for j in range(len2 + 1):
			d[i].append(0)

	for i in range(len1 + 1):
		d[i][0] = i

	for j in range(len2 + 1):
		d[0][j] = j

	for j in range(1, len2 + 1):
		for i in range(1, len1 + 1):
			if s1[i - 1] == s2[j - 1]:
				d[i][j] = d[i - 1][j - 1]
			else:
				d[i][j] = min(d[i - 1][j] + 1,  # deletion
							  d[i][j - 1] + 1,  # insertion
							  d[i - 1][j - 1] + 1)  # substitution

	return d[len1][len2]
	
	
func _on_timer_shutdown_timeout():
		get_tree().quit()
	
	
# Function to play "Rock,Paper,Scissors" with user input
func play_jun_ken_po(user_choice: String) -> String:
	var bot_choice = choices[randi() % choices.size()]
	
	# Ensure user input is valid
	var valid_choices = ["rock", "paper", "scissors"]
	if valid_choices.find(user_choice.to_lower()) == -1:
		return "Invalid choice! Please choose 'Rock', 'Paper', or 'Scissors'."
	
	var result = determine_winner(bot_choice, user_choice)
	
	return "You chose " + user_choice.capitalize() + ". I chose " + bot_choice.capitalize() + ". " + result

# Function to determine the winner
func determine_winner(bot_choice, user_choice) -> String:
	if bot_choice == user_choice:
		return "It's a tie!"
	elif ((bot_choice == "rock" and user_choice == "scissors") or
		 (bot_choice == "paper" and user_choice == "rock") or
		 (bot_choice == "scissors" and user_choice == "paper")):
		return "I win!"
	else:
		return "You win!"


