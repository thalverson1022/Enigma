extends RefCounted
## Shared copy patterns for Adventure flow screens.
##
## Keep this focused on durable labels and short instruction text. Narrative
## flavor, contract-specific story, and data-derived reward/pressure copy stay
## with the scenes or resources that own that context.

const ACTION_CHOOSE := "Choose"
const ACTION_CLOSE_MAP := "Close Map"
const ACTION_LEAVE_SHOP := "Leave Shop"
const ACTION_PROCEED := "Proceed"
const ACTION_RESUME_ADVENTURE := "Resume Adventure"
const ACTION_RESTART_ADVENTURE := "Restart Adventure"
const ACTION_RETRY_ENCOUNTER := "Retry Encounter"
const ACTION_SKIP_REWARD := "Skip Reward"
const ACTION_START_ADVENTURE := "New Adventure"
const ACTION_START_NEW_ADVENTURE := "Start New Adventure"

const PHASE_CONTRACT_OFFER := "Contract Offer"
const PHASE_CONTRACT_ROUTE_CHOOSE := "Contract Route - Choose Path"
const PHASE_CONTRACT_ROUTE_PLANNING := "Contract Route - Planning"
const PHASE_CONTRACT_VICTORY := "Contract Victory"
const PHASE_FIGHT_RESULT := "Fight Result"
const PHASE_FIGHTING := "Fighting"
const PHASE_REWARD_CHOICE := "Reward Choice"
const PHASE_RUN_FAILED := "Run Failed"
const PHASE_SHOP := "Shop"
const PHASE_SUBCLASS_CHOICE := "Subclass Choice"
const PHASE_TAVERN_PLANNING := "Tavern - Planning"
const PHASE_VICTORY_CLAIM_REWARD := "Victory - Claim Reward"

const NEXT_BUY_OR_LEAVE_SHOP := "Buy gear or leave the shop."
const NEXT_CHOOSE_REWARD := "Choose your reward."
const NEXT_CHOOSE_SECOND_SUBCLASS := "Choose your second subclass tree."
const NEXT_CHOOSE_NEXT_STEP := "Choose your next step."
const NEXT_CLAIM_REWARD := "Claim your reward."
const NEXT_FINISH_BUILD_TO_FIGHT := "Finish your build to fight."
const NEXT_FIGHT_WHEN_READY := "Fight when ready."
const NEXT_HEAR_CONTRACT_WINDOW := "Hear out the Contract Window."
const NEXT_LOCK_BUILD_THEN_FIGHT := "Lock your build, then fight."
const NEXT_REVIEW_FIGHT_RESULT := "Review the fight result."
const NEXT_RETRY_FIGHT := "Adjust your build, then retry the fight."
const NEXT_RESTART_ADVENTURE := "Restart your Adventure."
const NEXT_ROUTE_ON_MAP := "Choose your next route on the map."
const NEXT_START_NEW_ADVENTURE := "Start a new Adventure."
const NEXT_TAVERN_OPPONENT_ON_MAP := "Choose your next opponent on the map."

const STATUS_BUILD_AND_FIGHT := "Adjust your build, lock in, then fight."
const STATUS_RETRY_READY := "Retry ready. Adjust your build, lock in, then fight again."
const STATUS_SHOP_DECISION := "Spend gold or keep saving, then leave the shop."

const TOOLTIP_ADVENTURE_SEED := "Adventure seed used for combat, rewards, and shop rolls."
const TOOLTIP_NO_SAVED_ADVENTURE := "No saved Adventure to resume."
const TOOLTIP_ROUTE_NEEDS_SELECTION := "Select a route first."
const TOOLTIP_RANDOM_ADVENTURE_SEED := "Use a fresh random Adventure seed when starting a new run."
const TOOLTIP_SKIP_REWARD := "Decline these gear choices and continue."
const TOOLTIP_PRACTICE_ROOM := "Practice builds against a target dummy, freely."


static func selected_encounter_status(display_name: String) -> String:
	return "Selected: %s. %s" % [display_name, STATUS_BUILD_AND_FIGHT]


static func selected_route_status(display_name: String) -> String:
	return "Selected route: %s. %s" % [display_name, STATUS_BUILD_AND_FIGHT]


static func pending_route_status(display_name: String) -> String:
	return "Selected route: %s. Proceed to tune your build, lock in, and fight." % display_name


static func tooltip_mark_route(display_name: String) -> String:
	return "Proceed to %s as your next fight." % display_name


static func contract_accepted_status(display_name: String) -> String:
	return "Contract accepted: %s. Choose your route." % display_name


static func marked_target_story(display_name: String) -> String:
	return "%s is marked. Tune the build, lock in, and start the fight when ready." % display_name
