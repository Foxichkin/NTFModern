//Colonist
/datum/job/colonist
	title = "Colonist"
	paygrade = "C"
	outfit = /datum/outfit/job/other/colonist


/datum/outfit/job/other/colonist
	name = "Colonist"
	jobtype = /datum/job/colonist

	id = /obj/item/card/id
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine
	l_store = /obj/item/storage/pouch/survival/full
	r_store = /obj/item/radio


//Passenger
/datum/job/passenger
	title = "Passenger"
	paygrade = "C"


//Pizza Deliverer
/datum/job/pizza
	title = "Pizza Deliverer"
	access = ALL_MARINE_ACCESS
	minimal_access = ALL_MARINE_ACCESS
	outfit = /datum/outfit/job/other/pizza


/datum/outfit/job/other/pizza
	name = "Pizza Deliverer"
	jobtype = /datum/job/pizza

	id = /obj/item/card/id/silver
	w_uniform = /obj/item/clothing/under/pizza
	belt = /obj/item/weapon/gun/pistol/holdout
	shoes = /obj/item/clothing/shoes/red
	gloves = /obj/item/clothing/gloves/black
	head = /obj/item/clothing/head/soft/red
	r_store = /obj/item/radio
	l_store = /obj/item/reagent_containers/food/drinks/cans/dr_gibb
	back = /obj/item/storage/backpack/satchel
	r_hand = /obj/item/pizzabox/random


//Spatial Agent
/datum/job/spatial_agent
	title = "Spatial Agent"
	access = ALL_ACCESS
	minimal_access = ALL_ACCESS
	skills_type = /datum/skills/spatial_agent
	outfit = /datum/outfit/job/other/spatial_agent


/datum/outfit/job/other/spatial_agent
	name = "Spatial Agent"
	jobtype = /datum/job/spatial_agent

	id = /obj/item/card/id/silver
	w_uniform = /obj/item/clothing/under/rank/centcom_commander/sa
	belt = /obj/item/storage/belt/utility/full
	shoes = /obj/item/clothing/shoes/marinechief/sa
	gloves = /obj/item/clothing/gloves/marine/officer/chief/sa
	glasses = /obj/item/clothing/glasses/sunglasses/sa/nodrop
	back = /obj/item/storage/backpack/marine/satchel

/datum/job/spatial_agent/galaxy_red
	outfit = /datum/outfit/job/other/spatial_agent/galaxy_red

/datum/outfit/job/other/spatial_agent/galaxy_red
	w_uniform = /obj/item/clothing/under/liaison_suit/galaxy_red
	belt = null
	back = null

/datum/job/spatial_agent/galaxy_blue
	outfit = /datum/outfit/job/other/spatial_agent/galaxy_blue

/datum/outfit/job/other/spatial_agent/galaxy_blue
	w_uniform = /obj/item/clothing/under/liaison_suit/galaxy_blue
	belt = null
	back = null

/datum/job/spatial_agent/xeno_suit
	outfit = /datum/outfit/job/other/spatial_agent/xeno_suit

/datum/outfit/job/other/spatial_agent/xeno_suit
	head = /obj/item/clothing/head/xenos
	wear_suit = /obj/item/clothing/suit/xenos

/datum/job/spatial_agent/marine_officer
	outfit = /datum/outfit/job/other/spatial_agent/marine_officer

/datum/outfit/job/other/spatial_agent/marine_officer
	w_uniform = /obj/item/clothing/under/marine/officer/bridge
	head = /obj/item/clothing/head/beret/marine
	belt = /obj/item/storage/holster/belt/pistol/m4a3/officer
	back = null
	shoes = /obj/item/clothing/shoes/marine/full

/datum/job/zombie
	title = "Oh god run"

/datum/job/other/prisoner
	title = "Prisoner"
	paygrade = "Psnr"
	comm_title = "Psnr"
	outfit = /datum/outfit/job/prisoner
	supervisors = "Corpsec Officers"
	display_order = JOB_DISPLAY_ORDER_PRISONER
	skills_type = /datum/skills/civilian
	total_positions = -1
	selection_color = "#e69704"
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_OVERRIDELATEJOINSPAWN|JOB_FLAG_ADDTOMANIFEST
	job_category = JOB_CAT_CIVILIAN

/datum/outfit/job/prisoner
	id = /obj/item/card/id
	w_uniform = /obj/item/clothing/under/rank/prisoner
	shoes = /obj/item/clothing/shoes/orange
	ears = /obj/item/radio/headset/mainship

/datum/job/worker
	title = "Worker"
	paygrade = "Wrkr"
	comm_title = "Wrkr"
	outfit = /datum/outfit/job/worker
	supervisors = "Ninetails Corp"
	access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_CARGO, ACCESS_CIVILIAN_ENGINEERING)
	minimal_access = list(ACCESS_MARINE_ENGINEERING, ACCESS_MARINE_PREP, ACCESS_MARINE_MEDBAY, ACCESS_MARINE_DROPSHIP, ACCESS_MARINE_CARGO, ACCESS_CIVILIAN_ENGINEERING)
	skills_type = /datum/skills/civilian/survivor
	total_positions = -1
	selection_color = "#f3f70c"
	job_flags = JOB_FLAG_ROUNDSTARTJOINABLE|JOB_FLAG_LATEJOINABLE|JOB_FLAG_ALLOWS_PREFS_GEAR|JOB_FLAG_PROVIDES_BANK_ACCOUNT|JOB_FLAG_ADDTOMANIFEST
	faction = FACTION_TERRAGOV
	job_category = JOB_CAT_CIVILIAN

/datum/outfit/job/worker
	id = /obj/item/card/id
	w_uniform = /obj/item/clothing/under/colonist
	shoes = /obj/item/clothing/shoes/marine
	l_store = /obj/item/storage/pouch/survival/full
	ears = /obj/item/radio/headset/mainship
