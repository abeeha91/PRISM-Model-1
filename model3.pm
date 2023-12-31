
const int N = 5; // Number of validators
const int Initial = 0;
const int Deposit = 1;
const int Pending=2;
const int Activated = 3;
const int Slashed=4;
const int Exiting=5;
const int Exited=6;
const int Withdrawn=7;
const int Withdrawable = 8;
const int withdrawl_inactive=9;

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
const int UNSLASHED_WITHDRAWABLE_PERIOD = 27; // 0 epochs
const int SLASHED_WITHDRAWABLE_PERIOD = 4; // 4 epochs
const int WITHDRAWABLE_PHASE_START = 4; // 4 epochs for phase 2
const int MAX_VALUE = 1000; // Maximum value for withdrawal credentials/amounts
const int MAX_WITHDRAWALS_PROCESSED = 100; //track of the number of 
const int EXIT_DELAY=1;

formula exit_epoch_calc =
    ((current_slot + 1 + MAX_SEED_LOOKAHEAD) < FINALIZED_CHECKPOINT_EPOCH + MAX_SLOTS_PER_EPOCH) ? 
    (current_slot + 1 + MAX_SEED_LOOKAHEAD) :
    (((current_slot + 1 + MAX_SEED_LOOKAHEAD) < 2 * (FINALIZED_CHECKPOINT_EPOCH + MAX_SLOTS_PER_EPOCH)) ? 
    (current_slot + 1 + MAX_SEED_LOOKAHEAD - (FINALIZED_CHECKPOINT_EPOCH + MAX_SLOTS_PER_EPOCH)) :
    (current_slot + 1 + MAX_SEED_LOOKAHEAD - 2 * 
    (FINALIZED_CHECKPOINT_EPOCH + MAX_SLOTS_PER_EPOCH)));
//formula withdrawable_epoch_cal = exit_epoch + EXIT_DELAY + SLASHED_WITHDRAWAL_DELAY;
    



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
    status: [0..9]; // Validator statuses
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
    votes_cast: [0..2]; // vote cast counter
    exit_queue: [0..MAX_ACTIVE_VALIDATORS] init 0; // Track the exit queue
    pub_key:[0..6]; //pubkey
    balance:[0..MAX_BALANCES]; //balance 
    initial_balance:[0..32]; //initial balance of validator
    withdrawal_key: [0..6]; // Define the range of withdrawal credentials
    withdrawal_request_initiated: [0..1]; // 0 for not initiated, 1 for initiated
    withdrawal_amount: [0..MAX_BALANCES]; //Withdrawl amount 
    withdrawal_credentials:[0..MAX_VALUE];
    withdrawals_processed: [0..MAX_WITHDRAWALS_PROCESSED] init 0; // Initialized to zero initially


    


//inital stage when validator deposit pub_key and balance

[initial] status=Initial -> 1/32: (status'=1) & (balance' = initial_balance) &
                        (pub_key' = 1) & (withdrawal_key'=1) &(deposit_slot'=0) // Branch for slot 0
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=1) // Branch for slot 1
                    + 1/32: (status'=1) & (balance' = initial_balance) &
                    (pub_key' = 1) & (withdrawal_key'=1) & (deposit_slot'=2) // Branch for slot 2
                    + 1/32: (status'=1) &  (balance' = initial_balance) & 
                    (pub_key' = 1) &  (withdrawal_key'=1) &(deposit_slot'=3) // Branch for slot 3
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)&
                    (withdrawal_key'=1) & (deposit_slot'=4) // Branch for slot 4
                    + 1/32: (status'=1)  & (balance' = initial_balance) & 
                    (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=5) // Branch for slot 5
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=6) // Branch for slot 6
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)&  (withdrawal_key'=1) &(deposit_slot'=7) // Branch for slot 7
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1) & (withdrawal_key'=1) &(deposit_slot'=8) // Branch for slot 8
                    + 1/32: (status'=1) & (balance' = initial_balance) 
                    & (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=9) // Branch for slot 9
                    + 1/32: (status'=1) & (balance' = initial_balance) 
                    & (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=10) // Branch for slot 10
                    + 1/32: (status'=1) &  (balance' = initial_balance) 
                    & (pub_key' = 1)&  (withdrawal_key'=1) &(deposit_slot'=11) // Branch for slot 11
                    + 1/32: (status'=1) & (balance' = initial_balance) 
                    & (pub_key' = 1)&  (withdrawal_key'=1) &(deposit_slot'=12) // Branch for slot 12
                    + 1/32: (status'=1) & (balance' = initial_balance) 
                    & (pub_key' = 1)&  (withdrawal_key'=1) &(deposit_slot'=13) // Branch for slot 13
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)&  (withdrawal_key'=1) &(deposit_slot'=14) // Branch for slot 14
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=15) // Branch for slot 15
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)&  (withdrawal_key'=1) &(deposit_slot'=16) // Branch for slot 16
                    + 1/32: (status'=1) & (balance' = initial_balance) &
                     (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=17) // Branch for slot 17
                    + 1/32: (status'=1) & (withdrawal_key'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (deposit_slot'=18) // Branch for slot 18
                    + 1/32: (status'=1) &  (balance' = initial_balance) & 
                    (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=19) // Branch for slot 19
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=20) // Branch for slot 20
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                     (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=21) // Branch for slot 21
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=22) // Branch for slot 22
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)&  (withdrawal_key'=1) &(deposit_slot'=23) // Branch for slot 23
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=24) // Branch for slot 24
                    + 1/32: (status'=1) & (balance' = initial_balance) &
                     (pub_key' = 1)&  (withdrawal_key'=1) &(deposit_slot'=25) // Branch for slot 25
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)&  (withdrawal_key'=1) &(deposit_slot'=26) // Branch for slot 26
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)& (withdrawal_key'=1) & (deposit_slot'=27) // Branch for slot 27
                    + 1/32: (status'=1) & (withdrawal_key'=1) & (balance' = initial_balance) &
                     (pub_key' = 1)& (deposit_slot'=28) // Branch for slot 28
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1)&  (withdrawal_key'=1) &(deposit_slot'=29) // Branch for slot 29
                    + 1/32: (status'=1) & (balance' = initial_balance) & (pub_key' = 1)& 
                    (withdrawal_key'=1) &(deposit_slot'=30) // Branch for slot 30
                    + 1/32: (status'=1) & (balance' = initial_balance) & 
                    (pub_key' = 1) & (withdrawal_key'=1) & (deposit_slot'=31) // Branch for slot 31
                    & (activation_eligibility_epoch' = (activation_eligibility_epoch > 0)
                     ? activation_eligibility_epoch : (FINALIZED_CHECKPOINT_EPOCH + 1));

 // transition to deposit 
    [deposited] status=Deposit & current_slot=SLOT_DURATION 
        & (activation_eligibility_epoch <= FINALIZED_CHECKPOINT_EPOCH) & 
        (activation_epoch = 0) ->
        (status' = Pending) & (activation_epoch' = current_slot + 1);
//transition from deposit to pending
    

   [activate_pending_validator] status=Pending & deposit_slot < MAX_SLOTS_PER_EPOCH
        & (activation_eligibility_epoch <= FINALIZED_CHECKPOINT_EPOCH) &
         (activation_epoch = 0)
        & activated_in_epoch <= churn_limit ->
        (status' = Activated) & (activation_epoch' = current_slot + 1) 
        & (selected_slot' = deposit_slot) & (vote' = (activated_in_epoch < churn_limit ? 1 : 0));


// New transitions for alignment of activation eligibility epoch
   [update_activation_eligibility_epoch]
    status = Pending & activation_eligibility_epoch < FINALIZED_CHECKPOINT_EPOCH + 1 ->
    (activation_eligibility_epoch' = FINALIZED_CHECKPOINT_EPOCH + 1);

   [align_activation_epoch]
    status = Pending & activation_epoch > 0 & activation_epoch < FINALIZED_CHECKPOINT_EPOCH ->
    // Logic to align activation epoch with eligibility epoch within bounds
    (activation_epoch' = (activation_eligibility_epoch <= FINALIZED_CHECKPOINT_EPOCH) ? 
    activation_eligibility_epoch + DELAY_EPOCHS : activation_epoch);

    // transition for slot assignment
    [activate] status=Pending & activation_epoch > 0 & activation_epoch < FINALIZED_CHECKPOINT_EPOCH & vote=1 & activated_in_epoch < MAX_ACTIVE_VALIDATORS ->
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

    
    [activate_and_vote] status=Activated & activation_epoch > 0 & activation_epoch < FINALIZED_CHECKPOINT_EPOCH & votes_cast = 0 ->
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
         1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
        1/32: (status' = 3) & (votes_cast' = 1) +
       1/32: (status' = 3) & (votes_cast' = 1) +
       1/32: (status' = 3) & (votes_cast' = 1) +
       1/32: (status' = 3) & (votes_cast' = 1) +
       1/32: (status' = 3) & (votes_cast' = 1) ;


   // transition for casting vote
    [cast_vote] status=Activated & votes_cast < 2 -> 
        // Update the count of votes cast when a vote is cast
        (votes_cast' = votes_cast + 1);

    // Transition to check for double voting (casting 2 votes in allotted slot)
    [double_vote] status=Activated  & vote_attempt=1 & votes_cast = 2 -> 
        // Transition to Slashed status if double vote detected
        (status' = Slashed) & (penalty' = 5); 
    //transition for casting vote with low_balance    
    [low_balance_vote] status=Activated & balance <= 16 & 
       vote=1 & votes_cast < 2 -> (status'=Exiting) &
    // Action for adversary to cast a vote with low balance
       (votes_cast' = votes_cast + 1);
    
// Transition to initiate the exit process
    [initiate_exit] status=Activated & exit_epoch=0 ->
        (status' = Exiting) & (exit_epoch' = exit_epoch_calc) & 
        (withdrawable_epoch' = exit_epoch_calc + DELAY_EPOCHS);

// Transition to initiate the exit process due to insufficient balance
    [insufficient_balance] status=Activated & penalty<=16 ->
        (status' = Exiting) & (exit_epoch' = exit_epoch_calc) & 
        (withdrawable_epoch' = exit_epoch_calc + DELAY_EPOCHS);



// Transition to initiate voluntary exit meeting core criteria
    
    [voluntary_exit] status=Activated & exit_epoch=0 ->
       (status' = Exiting) & (exit_epoch' = current_slot) & 
        (withdrawable_epoch' = current_slot + DELAY_EPOCHS);

// Transition to slashed exit    
    [slashed_exited_to_withdrawable] status=Activated ->
       (exit_epoch' = exit_epoch_calc) &
       (withdrawable_epoch' = exit_epoch_calc + DELAY_EPOCHS);
// Transition to allow withdrawal after becoming Exited
    [withdraw] status=Exited & withdrawable_epoch = 0 ->
       (status' = Withdrawn) & 
       (withdrawable_epoch' = current_slot + WITHDRAWABLE_PHASE_START);   


    
endmodule

module Adversary
    // Flag to denote Adversary's vote attempt
    vote_attempt: [0..1] init 0; //0 for vote caste 1 for not cast

    // Adversary attempts a double vote
    [attempt_double_vote] vote_attempt=0 ->
        1: (vote_attempt' = 1); // The Adversary attempts a double vote

    // Adversary attempts to cast a vote with a low balance
    [low_balance_vote] vote_attempt=0 & balance <= 16 ->
        1: (vote_attempt' = 1); // The Adversary attempts to cast a vote with a low balance


endmodule