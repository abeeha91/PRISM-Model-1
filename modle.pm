const int N = 5; // Number of validators
const int initial = 0;
const int Deposit = 1;
const int Activated = 2;
const int Slashed=3;
const int Exiting=4;
const int Exited=5;
const int Withdrawn=6;
const int Withdrawable = 6;

const int PERSISTENT_COMMITTEE_PERIOD = 211;
const int FAR_FUTURE_EPOCH=100;
const int MAX_EFFECTIVE_BALANCE = 32; // Define the maximum effective balance
const int MAX_SLOTS_PER_EPOCH = 32; // Number of slots per epoch
const int SLOT_DURATION = 12; // Slot duration in seconds
const int MAX_ACTIVE_VALIDATORS = 4; // Maximum number of activated validators per epoch
const int FINALIZED_CHECKPOINT_EPOCH = 15; // Example value for finalized checkpoint epoch
const int MAX_TIME = MAX_SLOTS_PER_EPOCH; // Total number of slots (equivalent to 1 epoch)
const int DELAY_EPOCHS= 4;
const int EPOCHS_PER_SLASHINGS_VECTOR = 8192; // Define an appropriate value
const int MAX_SEED_LOOKAHEAD=4;
const int MAX_BALANCES=3200;
const int churn_limit=4;
const int SLASHED_EXIT_LOCK_PERIOD = 8192; // Approximately 36 days in epochs
const int UNSLASHED_EXIT_LOCK_PERIOD = 256; // Approximately 1 day in epochs
const int UNSLASHED_WITHDRAWABLE_PERIOD = 0; // 0 epochs
const int SLASHED_WITHDRAWABLE_PERIOD = 4; // 4 epochs
const int WITHDRAWABLE_PHASE_START = 4; // 4 epochs for phase 2
formula exit_epoch_calc =
    ((current_slot + 1 + MAX_SEED_LOOKAHEAD) < FINALIZED_CHECKPOINT_EPOCH + MAX_SLOTS_PER_EPOCH) ? 
    (current_slot + 1 + MAX_SEED_LOOKAHEAD) :
    (((current_slot + 1 + MAX_SEED_LOOKAHEAD) < 2 * (FINALIZED_CHECKPOINT_EPOCH + MAX_SLOTS_PER_EPOCH)) ? 
    (current_slot + 1 + MAX_SEED_LOOKAHEAD - (FINALIZED_CHECKPOINT_EPOCH + MAX_SLOTS_PER_EPOCH)) :
    (current_slot + 1 + MAX_SEED_LOOKAHEAD - 2 * 
    (FINALIZED_CHECKPOINT_EPOCH + MAX_SLOTS_PER_EPOCH)));



// Track time/slots
module time
    current_slot: [0..MAX_SLOTS_PER_EPOCH-1]; // Track the current slot

    // Define the progression mechanism to model slot durations (each slot is 12 seconds)
    [tick] current_slot < MAX_SLOTS_PER_EPOCH-1 -> 1 : (current_slot' = current_slot + 1);

    // After reaching the maximum slots in an epoch, reset to the beginning (cyclic model)
    [] current_slot = MAX_SLOTS_PER_EPOCH-1 -> 1 : (current_slot' = 0);

    

    
endmodule



// Track validator status and actions
module Validator_cycle
    status: [0..5]; // Validator statuses
    deposit_slot: [0..MAX_SLOTS_PER_EPOCH-1]; // Track the slot for deposit
    activation_eligibility_epoch: [0..FINALIZED_CHECKPOINT_EPOCH+MAX_SLOTS_PER_EPOCH]; // Activation eligibility epoch
    activation_epoch: [0..FINALIZED_CHECKPOINT_EPOCH+MAX_SLOTS_PER_EPOCH]; // Activation epoch
    count_active_validators: [0..MAX_ACTIVE_VALIDATORS]; // Track the count of active validators
    vote: [0..1]; // 0 for casting a vote, 1 for not casting
    selected_slot: [0..MAX_SLOTS_PER_EPOCH-1]; // Track the selected slot
    activated_in_epoch: [0..MAX_ACTIVE_VALIDATORS]; // Counter for validators activated in the epoch
    penalty: [0..MAX_EFFECTIVE_BALANCE];
    slashed: bool; // Slashed status
    exit_epoch: [0..FINALIZED_CHECKPOINT_EPOCH+MAX_SLOTS_PER_EPOCH];
    withdrawable_epoch: [0..FINALIZED_CHECKPOINT_EPOCH+MAX_SLOTS_PER_EPOCH];
    votes_cast: [0..2];
    exit_queue: [0..MAX_ACTIVE_VALIDATORS] init 0; // Track the exit queue
    pub_key:[0..6];
    balance:[0..MAX_BALANCES];
    initial_balance:[0..32];


   // Deposit transition with a delay of 1 epoch and random deposit_slot assignment
    [initial] status=0 -> 1/32: (status'=1) & (balance' = initial_balance) &
                        (pub_key' = 1) &(deposit_slot'=0) // Branch for slot 0
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (deposit_slot'=1) // Branch for slot 1
                    + 1/32: (status'=1) & (balance' = initial_balance) &
                    (pub_key' = 1) & (deposit_slot'=2) // Branch for slot 2
                    + 1/32: (status'=1) &  (balance' = initial_balance) & 
                    (pub_key' = 1) & (deposit_slot'=3) // Branch for slot 3
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)
                    & (deposit_slot'=4) // Branch for slot 4
                    + 1/32: (status'=1)  & (balance' = initial_balance) & 
                    (pub_key' = 1)& (deposit_slot'=5) // Branch for slot 5
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (deposit_slot'=6) // Branch for slot 6
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (deposit_slot'=7) // Branch for slot 7
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1) & (deposit_slot'=8) // Branch for slot 8
                    + 1/32: (status'=1) & (balance' = initial_balance) 
                    & (pub_key' = 1)& (deposit_slot'=9) // Branch for slot 9
                    + 1/32: (status'=1) & (balance' = initial_balance) 
                    & (pub_key' = 1)& (deposit_slot'=10) // Branch for slot 10
                    + 1/32: (status'=1) & (balance' = initial_balance) 
                    & (pub_key' = 1)& (deposit_slot'=11) // Branch for slot 11
                    + 1/32: (status'=1) & (balance' = initial_balance) 
                    & (pub_key' = 1)& (deposit_slot'=12) // Branch for slot 12
                    + 1/32: (status'=1) & (balance' = initial_balance) 
                    & (pub_key' = 1)& (deposit_slot'=13) // Branch for slot 13
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (deposit_slot'=14) // Branch for slot 14
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (deposit_slot'=15) // Branch for slot 15
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (deposit_slot'=16) // Branch for slot 16
                    + 1/32: (status'=1) & (balance' = initial_balance) &
                     (pub_key' = 1)& (deposit_slot'=17) // Branch for slot 17
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (deposit_slot'=18) // Branch for slot 18
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (deposit_slot'=19) // Branch for slot 19
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=20) // Branch for slot 20
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=21) // Branch for slot 21
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=22) // Branch for slot 22
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=23) // Branch for slot 23
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=24) // Branch for slot 24
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=25) // Branch for slot 25
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=26) // Branch for slot 26
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=27) // Branch for slot 27
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=28) // Branch for slot 28
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=29) // Branch for slot 29
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=30) // Branch for slot 30
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& (deposit_slot'=31) // Branch for slot 31
                    & (activation_eligibility_epoch' = (activation_eligibility_epoch > 0)
                     ? activation_eligibility_epoch : (FINALIZED_CHECKPOINT_EPOCH + 1));


    [deposited] status=1 & current_slot=SLOT_DURATION 
        & (activation_eligibility_epoch <= FINALIZED_CHECKPOINT_EPOCH) & 
        (activation_epoch = 0) ->
        (status' = 2) & (activation_epoch' = current_slot + 4);

    [activate_pending_validator] status=1 & deposit_slot < MAX_SLOTS_PER_EPOCH
        & (activation_eligibility_epoch <= FINALIZED_CHECKPOINT_EPOCH) &
         (activation_epoch = 0)
        & activated_in_epoch < churn_limit ->
        (status' = 1) & (activation_epoch' = current_slot + 1) 
        & (selected_slot' = deposit_slot) & (vote' = (activated_in_epoch < churn_limit ? 1 : 0));

    [activate] status=1 & activation_epoch > 0 & activation_epoch < FINALIZED_CHECKPOINT_EPOCH & vote=1 & activated_in_epoch < MAX_ACTIVE_VALIDATORS ->
        1/32: (selected_slot' = 0) & (activated_in_epoch' = activated_in_epoch + 1) +
        1/32: (selected_slot' = 1) & (activated_in_epoch' = activated_in_epoch + 1) +
        1/32: (selected_slot' = 2) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 3) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 4) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 5) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 6) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 7) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 8) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 9) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 10) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 11) & (activated_in_epoch' = activated_in_epoch + 1) +
        1/32: (selected_slot' = 12) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 13) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 14) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 15) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 16) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 17) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 18) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 19) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 20) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 21) & (activated_in_epoch' = activated_in_epoch + 1) +
        1/32: (selected_slot' = 22) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 23) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 24) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 25) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 26) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 27) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 28) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 29) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 30) & (activated_in_epoch' = activated_in_epoch + 1)+
        1/32: (selected_slot' = 31) & (activated_in_epoch' = activated_in_epoch + 1);

    [cast_vote] status=Activated & votes_cast < 2 -> 
        // Update the count of votes cast when a vote is cast
        (votes_cast' = votes_cast + 1);

    // Transition to check for double voting (casting 2 votes in allotted slot)
    [double_vote] status=Activated & votes_cast = 2 -> 
        // Transition to Slashed status if double vote detected
        (status' = Slashed) & (penalty' = 5); 

    [initiate_exit] status=Activated & exit_epoch=0 ->
    // Transition to initiate the exit process
    (status' = Exiting) & (exit_epoch' = exit_epoch_calc) & 
    (withdrawable_epoch' = exit_epoch_calc + DELAY_EPOCHS);


    [insufficient_balance] status=Activated & penalty<=16 ->
    // Transition to initiate the exit process due to insufficient balance
    (status' = Exiting) & (exit_epoch' = exit_epoch_calc) & 
    (withdrawable_epoch' = exit_epoch_calc + DELAY_EPOCHS);

    [voluntary_exit] status=Activated & exit_epoch=0 ->
    // Transition to initiate voluntary exit meeting core criteria
    // Optionally, add a condition for minimum service time if necessary
    (status' = Exiting) & (exit_epoch' = current_slot) & 
    (withdrawable_epoch' = current_slot + DELAY_EPOCHS);

    [slashed_exited_to_withdrawable] status=Activated ->
       (exit_epoch' = exit_epoch_calc) &
       (withdrawable_epoch' = exit_epoch_calc + DELAY_EPOCHS);
    

    
endmodule



module Validator2 = Validator_cycle [
    status = status_2,
    deposit_slot = deposit_slot_2,
    activation_eligibility_epoch = activation_eligibility_epoch_2,
    activation_epoch = activation_epoch_2,
    count_active_validators = count_active_validators_2,
    vote = vote_2,
    selected_slot = selected_slot_2,
    activated_in_epoch = activated_in_epoch_2,
    penalty = penalty_2,
    slashed = slashed_2,
    exit_epoch = exit_epoch_2,
    withdrawable_epoch = withdrawable_epoch_2,
    votes_cast = votes_cast_2,
    exit_queue = exit_queue_2,
    pub_key = pub_key_2,
    balance = balance_2,
    initial_balance = initial_balance_2
] endmodule

module Validator3 = Validator_cycle [
    status = status_3,
    deposit_slot = deposit_slot_3,
    activation_eligibility_epoch = activation_eligibility_epoch_3,
    activation_epoch = activation_epoch_3,
    count_active_validators = count_active_validators_3,
    vote = vote_3,
    selected_slot = selected_slot_3,
    activated_in_epoch = activated_in_epoch_3,
    penalty = penalty_3,
    slashed = slashed_3,
    exit_epoch = exit_epoch_3,
    withdrawable_epoch = withdrawable_epoch_3,
    votes_cast = votes_cast_3,
    exit_queue = exit_queue_3,
    pub_key = pub_key_3,
    balance = balance_3,
    initial_balance = initial_balance_3
] endmodule

module Validator4 = Validator_cycle [
    status = status_4,
    deposit_slot = deposit_slot_4,
    activation_eligibility_epoch = activation_eligibility_epoch_4,
    activation_epoch = activation_epoch_4,
    count_active_validators = count_active_validators_4,
    vote = vote_4,
    selected_slot = selected_slot_4,
    activated_in_epoch = activated_in_epoch_4,
    penalty = penalty_4,
    slashed = slashed_4,
    exit_epoch = exit_epoch_4,
    withdrawable_epoch = withdrawable_epoch_4,
    votes_cast = votes_cast_4,
    exit_queue = exit_queue_4,
    pub_key = pub_key_4,
    balance = balance_4,
    initial_balance = initial_balance_4
] endmodule

module Validator5 = Validator_cycle [
    status = status_5,
    deposit_slot = deposit_slot_5,
    activation_eligibility_epoch = activation_eligibility_epoch_5,
    activation_epoch = activation_epoch_5,
    count_active_validators = count_active_validators_5,
    vote = vote_5,
    selected_slot = selected_slot_5,
    activated_in_epoch = activated_in_epoch_5,
    penalty = penalty_5,
    slashed= slashed_5,
    exit_epoch = exit_epoch_5,
    withdrawable_epoch = withdrawable_epoch_5,
    votes_cast = votes_cast_5,
    exit_queue = exit_queue_5,
    pub_key = pub_key_5,
    balance= balance_5,
    initial_balance = initial_balance_5
] endmodule

module Validator6 = Validator_cycle [
    status = status_6,
    deposit_slot = deposit_slot_6,
    activation_eligibility_epoch = activation_eligibility_epoch_6,
    activation_epoch = activation_epoch_6,
    count_active_validators = count_active_validators_6,
    vote = vote_6,
    selected_slot = selected_slot_6,
    activated_in_epoch = activated_in_epoch_6,
    penalty = penalty_6,
    slashed= slashed_6,
    exit_epoch = exit_epoch_6,
    withdrawable_epoch= withdrawable_epoch_6,
    votes_cast = votes_cast_6,
    exit_queue = exit_queue_6,
    pub_key = pub_key_6,
    balance = balance_6,
    initial_balance = initial_balance_6
] endmodule
