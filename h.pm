const int N = 5; // Number of validators
const int Deposited = 0;
const int Pending = 1;
const int Activated = 2;
const int MAX_EFFECTIVE_BALANCE = 32; // Define the maximum effective balance
const int MAX_SLOTS_PER_EPOCH = 32; // Number of slots per epoch
const int SLOT_DURATION = 12; // Slot duration in seconds
const int MAX_ACTIVE_VALIDATORS = 4; // Maximum number of activated validators per epoch
const int FINALIZED_CHECKPOINT_EPOCH = 15; // Example value for finalized checkpoint epoch
const int MAX_TIME = MAX_SLOTS_PER_EPOCH; // Total number of slots (equivalent to 1 epoch)
const int DELAY_EPOCHS= 4;
formula churn_limit = max(4, 4 / 65536);
const double churn_limit_value= churn_limit;



// Track time/slots
module time
    current_slot: [0..MAX_SLOTS_PER_EPOCH-1]; // Track the current slot

    // Define the progression mechanism to model slot durations (each slot is 12 seconds)
    [tick] current_slot < MAX_SLOTS_PER_EPOCH-1 -> 1 : (current_slot' = current_slot + 1);

    // After reaching the maximum slots in an epoch, reset to the beginning (cyclic model)
    [] current_slot = MAX_SLOTS_PER_EPOCH-1 -> 1 : (current_slot' = 0);
endmodule

// Track validator status and actions
module validator_cycle
    status: [0..2]; // Validator statuses
    deposit_slot: [0..MAX_SLOTS_PER_EPOCH-1]; // Track the slot for deposit
    activation_eligibility_epoch: [0..FINALIZED_CHECKPOINT_EPOCH+MAX_SLOTS_PER_EPOCH]; // Activation eligibility epoch
    activation_epoch: [0..FINALIZED_CHECKPOINT_EPOCH+MAX_SLOTS_PER_EPOCH]; // Activation epoch
    count_active_validators: [0..MAX_ACTIVE_VALIDATORS]; // Track the count of active validators
    vote: [0..1]; // 0 for casting a vote, 1 for not casting
    selected_slot: [0..MAX_SLOTS_PER_EPOCH-1]; // Track the selected slot
    activated_in_epoch: [0..MAX_ACTIVE_VALIDATORS]; // Counter for validators activated in the epoch

   // Deposit transition with a delay of 1 epoch and random deposit_slot assignment
    [deposit] status=0 -> 1/32: (status'=1) & (deposit_slot'=0) // Branch for slot 0
                    + 1/32: (status'=1) & (deposit_slot'=1) // Branch for slot 1
                    + 1/32: (status'=1) & (deposit_slot'=2) // Branch for slot 2
                    + 1/32: (status'=1) & (deposit_slot'=3) // Branch for slot 3
                    + 1/32: (status'=1) & (deposit_slot'=4) // Branch for slot 4
                    + 1/32: (status'=1) & (deposit_slot'=5) // Branch for slot 5
                    + 1/32: (status'=1) & (deposit_slot'=6) // Branch for slot 6
                    + 1/32: (status'=1) & (deposit_slot'=7) // Branch for slot 7
                    + 1/32: (status'=1) & (deposit_slot'=8) // Branch for slot 8
                    + 1/32: (status'=1) & (deposit_slot'=9) // Branch for slot 9
                    + 1/32: (status'=1) & (deposit_slot'=10) // Branch for slot 10
                    + 1/32: (status'=1) & (deposit_slot'=11) // Branch for slot 11
                    + 1/32: (status'=1) & (deposit_slot'=12) // Branch for slot 12
                    + 1/32: (status'=1) & (deposit_slot'=13) // Branch for slot 13
                    + 1/32: (status'=1) & (deposit_slot'=14) // Branch for slot 14
                    + 1/32: (status'=1) & (deposit_slot'=15) // Branch for slot 15
                    + 1/32: (status'=1) & (deposit_slot'=16) // Branch for slot 16
                    + 1/32: (status'=1) & (deposit_slot'=17) // Branch for slot 17
                    + 1/32: (status'=1) & (deposit_slot'=18) // Branch for slot 18
                    + 1/32: (status'=1) & (deposit_slot'=19) // Branch for slot 19
                    + 1/32: (status'=1) & (deposit_slot'=20) // Branch for slot 20
                    + 1/32: (status'=1) & (deposit_slot'=21) // Branch for slot 21
                    + 1/32: (status'=1) & (deposit_slot'=22) // Branch for slot 22
                    + 1/32: (status'=1) & (deposit_slot'=23) // Branch for slot 23
                    + 1/32: (status'=1) & (deposit_slot'=24) // Branch for slot 24
                    + 1/32: (status'=1) & (deposit_slot'=25) // Branch for slot 25
                    + 1/32: (status'=1) & (deposit_slot'=26) // Branch for slot 26
                    + 1/32: (status'=1) & (deposit_slot'=27) // Branch for slot 27
                    + 1/32: (status'=1) & (deposit_slot'=28) // Branch for slot 28
                    + 1/32: (status'=1) & (deposit_slot'=29) // Branch for slot 29
                    + 1/32: (status'=1) & (deposit_slot'=30) // Branch for slot 30
                    + 1/32: (status'=1) & (deposit_slot'=31) // Branch for slot 31
                    & (activation_eligibility_epoch' = (activation_eligibility_epoch > 0)
                     ? activation_eligibility_epoch : (FINALIZED_CHECKPOINT_EPOCH + 1));


    [queue_to_pending] status=1 & current_slot=SLOT_DURATION & 
        (activation_eligibility_epoch <= FINALIZED_CHECKPOINT_EPOCH) & (activation_epoch = 0) ->
        (status' = 2) & (activation_epoch' = current_slot + 4);



    [activate] status=1 & activation_eligibility_epoch <= FINALIZED_CHECKPOINT_EPOCH 
        & activation_epoch=FINALIZED_CHECKPOINT_EPOCH+MAX_SLOTS_PER_EPOCH 
        & count_active_validators <= MAX_ACTIVE_VALIDATORS ->
        (activated_in_epoch < churn_limit*1.0) :
        // Activation logic when churn limit not reached
        (status'=2) & (activation_epoch' = current_slot + 4) 
        & (count_active_validators' = count_active_validators + 1) 
        & (activated_in_epoch' = activated_in_epoch + 1)
        + (activated_in_epoch >= churn_limit) :
        // Defer activation logic when churn limit reached
        (status'=1) & (activation_epoch' = current_slot + DELAY_EPOCHS);

    
                    



    
endmodule
