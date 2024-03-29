#ifndef __VCX_H
#define __VCX_H

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
  none = 0,
  initialized,
  offer_sent,
  request_received,
  accepted,
  unfulfilled,
  expired,
  revoked,
} vcx_state_t;

typedef enum {
  undefined = 0,
  validated = 1,
  invalid = 2,
} vcx_proof_state_t;

typedef unsigned int vcx_error_t;
typedef unsigned int vcx_schema_handle_t;
typedef unsigned int vcx_credentialdef_handle_t;
typedef unsigned int vcx_connection_handle_t;
typedef unsigned int vcx_credential_handle_t;
typedef unsigned int vcx_proof_handle_t;
typedef unsigned int vcx_command_handle_t;
typedef unsigned int vcx_search_handle_t;
typedef unsigned int vcx_bool_t;
typedef unsigned int vcx_payment_handle_t;
typedef unsigned int vcx_u32_t;
typedef SInt32 VcxHandle;
typedef const uint8_t vcx_data_t;
typedef unsigned long long vcx_u64_t;
typedef unsigned int vcx_wallet_backup_handle_t;

typedef struct
{

  union {
    vcx_schema_handle_t schema_handle;
    vcx_credentialdef_handle_t credentialdef_handle;
    vcx_connection_handle_t connection_handle;
    vcx_credential_handle_t credential_handle;
    vcx_proof_handle_t proof_handle;
  } handle;

  vcx_error_t status;
  char *msg;

} vcx_status_t;

/** Initialize Sovtoken & nullpay*/
vcx_error_t sovtoken_init();
//vcx_error_t nullpay_init();

/**
 * Initialize the SDK
 */

vcx_error_t vcx_agent_provision_async(vcx_command_handle_t handle, const char *json, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, const char *config));

// Provision an agent in the agency, populate configuration and wallet for this agent.
// NOTE: for asynchronous call use vcx_agent_provision_async
//
// #Params
// json: configuration
//
// #Returns
// Configuration (wallet also populated), on error returns NULL
char *vcx_provision_agent(const char *json);

const char *vcx_provision_agent_with_token(const char *json, const char *token);

vcx_error_t vcx_provision_agent_with_token_async(vcx_command_handle_t handle, const char *json, const char *token, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, const char *config));

vcx_error_t vcx_get_provision_token(vcx_command_handle_t handle, const char *config, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, const char *token));


vcx_error_t vcx_agent_update_info(vcx_command_handle_t handle, const char *json, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err));
//pub extern fn vcx_agent_update_info(command_handle : u32, json: *const c_char, cb: Option<extern fn(xcommand_handle: u32, err: u32, config: *const c_char)>) -> u32

vcx_error_t vcx_init_with_config(vcx_command_handle_t handle, const char *config, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err));

vcx_error_t vcx_init_pool(vcx_command_handle_t command_handle, const char *pool_config, void (*cb)(vcx_command_handle_t, vcx_error_t));

vcx_error_t vcx_init(vcx_command_handle_t handle, const char *config_path, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err));
//pub extern fn vcx_init (command_handle: u32, config_path:*const c_char, cb: Option<extern fn(xcommand_handle: u32, err: u32)>) -> u32

vcx_error_t vcx_create_agent(vcx_command_handle_t handle, const char *config, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err, const char *xconfig));
vcx_error_t vcx_update_agent_info(vcx_command_handle_t handle, const char *info, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err));

const char *vcx_error_c_message(int);
const char *vcx_version();

vcx_error_t vcx_get_current_error(const char ** error_json_p);

/**
 * Schema object
 *
 * For creating, validating and committing a schema to the sovrin ledger.
 *

** Populates status with the current state of this credential. *
vcx_error_t vcx_schema_serialize(vcx_command_handle_t command_handle, vcx_schema_handle_t schema_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *state));

** Re-creates a credential object from the specified serialization. *
vcx_error_t vcx_schema_deserialize(vcx_command_handle_t command_handle, const char *serialized_schema, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_schema_handle_t schema_handle));

/** Populates data with the contents of the schema handle. */
vcx_error_t vcx_schema_get_attributes(vcx_command_handle_t command_handle, const char *source_id, vcx_schema_handle_t sequence_no, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *schema_attrs));

/**Populates sequence_no with the actual sequence number of the schema on the sovrin ledger.*/
vcx_error_t vcx_schema_get_sequence_no(vcx_command_handle_t command_handle, vcx_schema_handle_t schema_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_schema_handle_t sequence_no));

/** Release memory associated with schema object. *
vcx_error_t vcx_schema_release(vcx_schema_handle_t handle);
*/

/**
 * credentialdef object
 *
 * For creating, validating and committing a credential definition to the sovrin ledger.
 */

/** Populates status with the current state of this credential. */
//vcx_error_t vcx_credentialdef_serialize(vcx_command_handle_t command_handle, vcx_credentialdef_handle_t credentialdef_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *state));

/** Re-creates a credential object from the specified serialization. */
//vcx_error_t vcx_credentialdef_deserialize(vcx_command_handle_t command_handle, const char *serialized_credentialdef, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_credentialdef_handle_t credentialdef_handle));

/** Asynchronously commits the credentialdef to the ledger.  */
//vcx_error_t vcx_credentialdef_commit(vcx_credentialdef_handle_t credentialdef_handle);

/** Populates sequence_no with the actual sequence number of the credentialdef on the sovrin ledger. */
vcx_error_t vcx_credentialdef_get_sequence_no(vcx_credentialdef_handle_t credentialdef_handle, int *sequence_no);

/** Populates data with the contents of the credentialdef handle. */
vcx_error_t vcx_credentialdef_get(vcx_credentialdef_handle_t credentialdef_handle, char *data);

/**
 * connection object
 *
 * For creating a connection with an identity owner for interactions such as exchanging
 * credentials and proofs.
 */

/** Creates a connection object to a specific identity owner. Populates a handle to the new connection. */
vcx_error_t vcx_connection_create(vcx_command_handle_t command_handle, const char *source_id, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, vcx_connection_handle_t connection_handle));

/** Asynchronously request a connection be made. */
vcx_error_t vcx_connection_connect(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, const char *connection_type, void (*cb)(vcx_command_handle_t, vcx_error_t err));

/** Accept connection for the given invitation. */
vcx_error_t vcx_connection_accept_connection_invite(vcx_command_handle_t command_handle, const char *source_id, const char *invite_details, const char *connection_type, void (*cb)(vcx_command_handle_t, vcx_error_t errer, vcx_connection_handle_t connection_handle, const char *connection_serialized));

/** Returns the contents of the connection handle or null if the connection does not exist. */
vcx_error_t vcx_connection_serialize(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *state));

/** Re-creates a connection object from the specified serialization. */
vcx_error_t vcx_connection_deserialize(vcx_command_handle_t command_handle, const char *serialized_credential, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_connection_handle_t connection_handle));

/** Request a state update from the agent for the given connection. */
vcx_error_t vcx_connection_update_state(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Update the state of the connection based on the given message. */
vcx_error_t vcx_connection_update_state_with_message(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, const char *message, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Retrieves the state of the connection */
vcx_error_t vcx_connection_get_state(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Releases the connection from memory. */
vcx_error_t vcx_connection_release(vcx_connection_handle_t connection_handle);

/** Get the invite details for the connection. */
vcx_error_t vcx_connection_invite_details(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, int abbreviated, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *details));

/** Creates a connection from the invite details. */
vcx_error_t vcx_connection_create_with_invite(vcx_command_handle_t command_handle, const char *source_id, const char *invite_details, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_connection_handle_t connection_handle));

/** Create a Connection object that provides an Out-of-Band Connection for an institution's user. */
vcx_error_t vcx_connection_create_outofband(vcx_command_handle_t command_handle, const char *source_id, const char *goal_code, const char *goal, int handshake, const char *request_attach, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_connection_handle_t connection_handle));

/** Create a Connection object from the given Out-of-Band Invitation. */
vcx_error_t vcx_connection_create_with_outofband_invitation(vcx_command_handle_t command_handle, const char *source_id, const char *invite, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_connection_handle_t connection_handle));

/** Deletes a connection, send an API call to agency to stop sending messages from this connection */
vcx_error_t vcx_connection_delete_connection(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t, vcx_error_t err));

/** Get Problem Report message for Connection object in Failed or Rejected state. */
vcx_error_t vcx_connection_get_problem_report(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t, vcx_error_t err));

/** Send a message to the specified connection
///
/// #params
///
/// command_handle: command handle to map callback to user context.
///
/// connection_handle: connection to receive the message
///
/// msg: actual message to send
///
/// send_message_options: config options json string that contains following options
///     {
///         msg_type: String, // type of message to send
///         msg_title: String, // message title (user notification)
///         ref_msg_id: Option<String>, // If responding to a message, id of the message
///     }
///
///
/// cb: Callback that provides array of matching messages retrieved
///
/// #Returns
/// Error code as a u32
 */
vcx_error_t vcx_connection_send_message(vcx_command_handle_t command_handle,
                                        vcx_connection_handle_t connection_handle,
                                        const char *msg,
                                        const char *send_message_options,
                                        void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *msg_id));

/** Generate a signature for the specified data */
vcx_error_t vcx_connection_sign_data(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, uint8_t const* data_raw, unsigned int data_len, void (*cb)(vcx_command_handle_t, vcx_error_t err, uint8_t const* signature_raw, unsigned int signature_len));

/** Verify the signature is valid for the specified data */
vcx_error_t vcx_connection_verify_signature(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, uint8_t const* data_raw, unsigned int data_len, uint8_t const* signature_raw, unsigned int signature_len, void (*cb)(vcx_command_handle_t, vcx_error_t err, vcx_bool_t valid));

/** Send trust ping message to the specified connection to prove that two agents have a functional pairwise channel. */
vcx_error_t vcx_connection_send_ping(vcx_command_handle_t command_handle,
                                     vcx_connection_handle_t connection_handle,
                                     const char *comment,
                                     void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

/** Send a message to reuse existing Connection instead of setting up a new one as response on received Out-of-Band Invitation. */
vcx_error_t vcx_connection_send_reuse(vcx_command_handle_t command_handle,
                                      vcx_connection_handle_t connection_handle,
                                      const char *invite,
                                      void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

/** Send answer on received question message according to Aries question-answer protocol. */
vcx_error_t vcx_connection_send_answer(vcx_command_handle_t command_handle,
                                      vcx_connection_handle_t connection_handle,
                                      const char *question,
                                      const char *answer,
                                      void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

/** Send a message to invite another side to take a particular action. */
vcx_error_t vcx_connection_send_invite_action(vcx_command_handle_t command_handle,
                                              vcx_connection_handle_t connection_handle,
                                              const char *goal_code,
                                              void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *message));

/**
 * credential issuer object
 *
 * Used for offering and managing a credential with an identity owner.
 */

/** Creates a credential object from the specified credentialdef handle. Populates a handle the new credential. */
//vcx_error_t vcx_issuer_create_credential(vcx_command_handle_t command_handle, const char *source_id, vcx_schema_handle_t schema_seq_no, const char *issuer_did, const char *credential_data, const char *credential_name, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, vcx_credential_handle_t credential_handle));

/** Asynchronously sends the credential offer to the connection. */
//vcx_error_t vcx_issuer_send_credential_offer(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

/** Updates the state of the credential from the agency. */
//vcx_error_t vcx_issuer_credential_update_state(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Retrieves the state of the issuer_credential. */
//vcx_error_t vcx_issuer_credential_get_state(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Asynchronously send the credential to the connection. Populates a handle to the new transaction. */
//vcx_error_t vcx_issuer_send_credential(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err));

/** Populates status with the current state of this credential. */
//vcx_error_t vcx_issuer_credential_serialize(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *state));

/** Re-creates a credential object from the specified serialization. */
//vcx_error_t vcx_issuer_credential_deserialize(vcx_command_handle_t, const char *serialized_credential, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_credential_handle_t credential_handle));

/** Terminates a credential for the specified reason. */
//vcx_error_t vcx_issuer_terminate_credential(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, vcx_state_t state_type, const char *msg);

/** Releases the credential from memory. */
//vcx_error_t vcx_issuer_credential_release(vcx_credential_handle_t credential_handle);

/** Populates credential_request with the latest credential request received. (not in MVP) */
//vcx_error_t vcx_issuer_get_credential_request(vcx_credential_handle_t credential_handle, char *credential_request);

/** Sets the credential request in an accepted state. (not in MVP) */
vcx_error_t vcx_issuer_accept_credential(vcx_credential_handle_t credential_handle);

vcx_error_t vcx_issuer_credential_get_problem_report(vcx_command_handle_t command_handle,
                                                     vcx_credential_handle_t credential_handle,
                                                     void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/**
 * proof object
 *
 * Used for requesting and managing a proof request with an identity owner.
 */

/** Creates a proof object.  Populates a handle to the new proof. */
vcx_error_t vcx_proof_create(vcx_command_handle_t command_handle, const char *source_id, const char *requested_attrs, const char *requested_predicates, const char *revocation_interval, const char *name, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, vcx_proof_handle_t proof_handle));

/** Create a new Proof object based on the given Presentation Proposal message. */
vcx_error_t vcx_proof_create_with_proposal(vcx_command_handle_t command_handle, const char *source_id, const char *presentation_proposal, const char *name, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, vcx_proof_handle_t proof_handle));

/** Asynchronously send a proof request to the connection. */
vcx_error_t vcx_proof_send_request(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

vcx_error_t vcx_proof_set_connection(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

/** Asynchronously send a new proof request to the connection. */
vcx_error_t vcx_proof_request_proof(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, vcx_connection_handle_t connection_handle, const char *requested_attrs, const char *requested_predicates, const char *revocation_interval, const char *name, void (*cb)(vcx_command_handle_t, vcx_error_t));

/** Populate response_data with the latest proof offer received. */
vcx_error_t vcx_get_proof(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_proof_state_t state, const char *proof_string));

/** Returns a proof request message */
vcx_error_t vcx_proof_get_request_msg(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/** Returns a proof proposal received */
vcx_error_t vcx_get_proof_proposal(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/** Returns a proof message */
vcx_error_t vcx_get_proof_msg(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/** Get the proof request attachment that you send along the out of band credential */
vcx_error_t vcx_proof_get_request_attach(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/** Populates status with the current state of this proof request. */
vcx_error_t vcx_proof_update_state(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Update the state of the proof based on the given message. */
vcx_error_t vcx_proof_update_state_with_message(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, const char *message, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Retrieves the state of the proof. */
vcx_error_t vcx_proof_get_state(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Populates status with the current state of this proof. */
vcx_error_t vcx_proof_serialize(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *state));

/** Re-creates a proof object from the specified serialization. */
vcx_error_t vcx_proof_deserialize(vcx_command_handle_t command_handle, const char *serialized_proof, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_proof_handle_t proof_handle));

/** Releases the proof from memory. */
vcx_error_t vcx_proof_release(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle);

/** Get Problem Report message for Proof object in Failed or Rejected state. */
vcx_error_t vcx_proof_get_problem_report(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/**
 * disclosed_proof object
 *
 * Used for sending a disclosed_proof to an identity owner.
 */

/** Creates a disclosed_proof object from a proof request.  Populates a handle to the new disclosed_proof. */
vcx_error_t vcx_disclosed_proof_create_with_request(vcx_command_handle_t command_handle, const char *source_id, const char *proof_req, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, vcx_proof_handle_t proof_handle));

/** Creates a disclosed_proof object from a msgid.  Populates a handle to the new disclosed_proof. */
vcx_error_t vcx_disclosed_proof_create_with_msgid(vcx_command_handle_t command_handle, const char *source_id, vcx_connection_handle_t connectionHandle, const char *msg_id, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, vcx_proof_handle_t proof_handle, const char *proof_request));

/** Creates a disclosed_proof object from a proposal. Populates a handle to the new disclosed_proof. */
vcx_error_t vcx_disclosed_proof_create_proposal(vcx_command_handle_t command_handle, const char *source_id, const char *proposal, const char *comment, void (*cb)(vcx_command_handle_t, vcx_error_t, vcx_proof_handle_t));

/** Asynchronously send a proof to the connection. */
vcx_error_t vcx_disclosed_proof_send_proof(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

/** Asynchronously send a proposal to the connection. */
vcx_error_t vcx_disclosed_proof_send_proposal(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t, vcx_error_t));

/** Asynchronously send reject of a proof to the connection. */
vcx_error_t vcx_disclosed_proof_reject_proof(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

/** Get proof msg */
vcx_error_t vcx_disclosed_proof_get_proof_msg(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *msg));

/** Get proof reject msg */
vcx_error_t vcx_disclosed_proof_get_reject_msg(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *msg));

/** Asynchronously redirect a connection. */
vcx_error_t vcx_connection_redirect(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, vcx_connection_handle_t redirect_connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

/** Get redirect details. */
vcx_error_t vcx_connection_get_redirect_details(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *details));

/** Populates status with the current state of this disclosed_proof request. */
vcx_error_t vcx_disclosed_proof_update_state(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Checks for any state change from the given message and updates the state attribute. */
vcx_error_t vcx_disclosed_proof_update_state_with_message(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, const char *message, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Check for any proof requests from the connection. */
vcx_error_t vcx_disclosed_proof_get_requests(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *requests));

/** Retrieves the state of the disclosed_proof. */
vcx_error_t vcx_disclosed_proof_get_state(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Populates status with the current state of this disclosed_proof. */
vcx_error_t vcx_disclosed_proof_serialize(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *proof_request));

/** Re-creates a disclosed_proof object from the specified serialization. */
vcx_error_t vcx_disclosed_proof_deserialize(vcx_command_handle_t command_handle, const char *serialized_proof, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_proof_handle_t proof_handle));

/** Takes the disclosed proof object and returns a json string of all credentials matching associated proof request from wallet */
vcx_error_t vcx_disclosed_proof_retrieve_credentials(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *matching_credentials));

/** Takes the disclosed proof object and generates a proof from the selected credentials and self attested attributes */
vcx_error_t vcx_disclosed_proof_generate_proof(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, const char *selected_credentials, const char *self_attested_attrs, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

/** Releases the disclosed_proof from memory. */
vcx_error_t vcx_disclosed_proof_release(vcx_proof_handle_t proof_handle);

/** Declines presentation request. */
vcx_error_t vcx_disclosed_proof_decline_presentation_request(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, vcx_connection_handle_t connection_handle, const char *reason, const char *proposal, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

/** Get Problem Report message for Disclosed Proof object in Failed or Rejected state. */
vcx_error_t vcx_disclosed_proof_get_problem_report(vcx_command_handle_t command_handle, vcx_proof_handle_t proof_handle, void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/**
 * credential object
 *
 * Used for accepting and requesting a credential with an identity owner.
 */

/** Retrieve information about a stored credential in user's wallet, including credential id and the credential itself. */
vcx_error_t vcx_get_credential(vcx_command_handle_t handle, vcx_credential_handle_t credential_handle, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, const char *credential));

/** Delete a Credential associated with the state object from the Wallet and release handle of the state object. */
vcx_error_t vcx_delete_credential(vcx_command_handle_t handle, vcx_credential_handle_t credential_handle, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, const char *credential));

/** Creates a credential object from the specified credentialdef handle. Populates a handle the new credential. */
vcx_error_t vcx_credential_create_with_offer(vcx_command_handle_t command_handle, const char *source_id, const char *credential_offer, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, vcx_credential_handle_t credential_handle));

/** Creates a credential object from the connection and msg id. Populates a handle the new credential. */
vcx_error_t vcx_credential_create_with_msgid(vcx_command_handle_t command_handle, const char *source_id, vcx_connection_handle_t connection, const char *msg_id, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, vcx_credential_handle_t credential_handle, const char* credential_offer));

/** Accept credential for the given offer. */
vcx_error_t vcx_credential_accept_credential_offer(vcx_command_handle_t command_handle, const char *source_id, const char *credential_offer, vcx_connection_handle_t connection, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, vcx_credential_handle_t credential_handle, const char* credential_serialized));

/** Asynchronously sends the credential request to the connection. */
vcx_error_t vcx_credential_send_request(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, vcx_connection_handle_t connection_handle, vcx_payment_handle_t payment_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err));

/** Check for any credential offers from the connection. */
vcx_error_t vcx_credential_get_offers(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *offers));

/** Updates the state of the credential from the agency. */
vcx_error_t vcx_credential_update_state(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Update the state of the credential based on the given message. */
vcx_error_t vcx_credential_update_state_with_message(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, const char *message, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Retrieves the state of the credential - including storing the credential if it has been sent. */
vcx_error_t vcx_credential_get_state(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_state_t state));

/** Populates status with the current state of this credential. */
vcx_error_t vcx_credential_serialize(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, const char *state));

/** Re-creates a credential from the specified serialization. */
vcx_error_t vcx_credential_deserialize(vcx_command_handle_t, const char *serialized_credential, void (*cb)(vcx_command_handle_t xcommand_handle, vcx_error_t err, vcx_credential_handle_t credential_handle));

/** Releases the credential from memory. */
vcx_error_t vcx_credential_release(vcx_credential_handle_t credential_handle);

/** Send a Credential rejection to the connection. */
vcx_error_t vcx_credential_reject(vcx_command_handle_t command_handle, vcx_credential_handle_t handle, vcx_connection_handle_t connection_handle, const char *comment, void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/** Build Presentation Proposal message for revealing Credential data. */
vcx_error_t vcx_credential_get_presentation_proposal_msg(vcx_command_handle_t handle, vcx_credential_handle_t credential_handle, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err, const char *presentation_proposal));

/** Get Problem Report message for Credential object in Failed or Rejected state. */
vcx_error_t vcx_credential_get_problem_report(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/** Retrieve information about a stored credential. */
vcx_error_t vcx_credential_get_info(vcx_command_handle_t command_handle, vcx_credential_handle_t credential_handle, void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/**
 * wallet object
 *
 * Used for exporting and importing and managing the wallet.
 */

/** Export the wallet as an encrypted file */
vcx_error_t vcx_wallet_export(vcx_command_handle_t handle, const char *path, const char *backup_key, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err));

/** Import an encrypted file back into the wallet */
vcx_error_t vcx_wallet_import(vcx_command_handle_t handle, const char *config, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err));

/** Add a record inside a wallet */
vcx_error_t vcx_wallet_add_record(vcx_command_handle_t chandle, const char * type_, const char *record_id, const char *record_value, const char *tags_json, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err));

/** Get a record from wallet */
vcx_error_t vcx_wallet_get_record(vcx_command_handle_t chandle, const char * type_, const char *record_id, const char *options, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err, const char *record_json));

/** Delete a record from wallet */
vcx_error_t vcx_wallet_delete_record(vcx_command_handle_t chandle, const char * type_, const char *record_id, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err));

/** Update a record in wallet if it is already added */
vcx_error_t vcx_wallet_update_record_value(vcx_command_handle_t chandle, const char *type_, const char *record_id, const char *record_value, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err));

/** Adds tags to a record in the wallet */
vcx_error_t vcx_wallet_add_record_tags(vcx_command_handle_t chandle, const char *type_, const char *record_id, const char *tags, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err));

/** Updates tags of a record in the wallet */
vcx_error_t vcx_wallet_update_record_tags(vcx_command_handle_t chandle, const char *type_, const char *record_id, const char *tags, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err));

/** Deletes tags from a record in the wallet */
vcx_error_t vcx_wallet_delete_record_tags(vcx_command_handle_t chandle, const char *type_, const char *record_id, const char *tags, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err));

/** Search for records in the wallet */
vcx_error_t vcx_wallet_open_search(vcx_command_handle_t chandle, const char *type_, const char *query_json, const char *options_json, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err, vcx_search_handle_t search_handle));

/** Search for records in the wallet */
vcx_error_t vcx_wallet_search_next_records(vcx_command_handle_t chandle, vcx_search_handle_t search_handle, vcx_u32_t count, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err, const char *records_json));

/** Close a search */
vcx_error_t vcx_wallet_close_search(vcx_command_handle_t chandle, vcx_search_handle_t search_handle, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err));

/**
 * token object
 */

/** Create payment address for using tokens */
vcx_error_t vcx_wallet_create_payment_address(vcx_command_handle_t chandle, const char *seed, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err, const char *address));

/** Get wallet token info which contains balance and addresses */
vcx_error_t vcx_wallet_get_token_info(vcx_command_handle_t chandle, vcx_payment_handle_t payment_handle, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err, const char *token_info));

/** Send tokens from wallet to a recipient address */
vcx_error_t vcx_wallet_send_tokens(vcx_command_handle_t chandle, vcx_payment_handle_t payment_handle, const char* tokens, const char* recipient, void (*cb)(vcx_command_handle_t xhandle, vcx_error_t err, const char *recipient));

/** Shutdown vcx wallet */
vcx_error_t vcx_shutdown(vcx_bool_t deleteWallet);

/** Get Messages (Connections) of given status */
vcx_error_t vcx_messages_download( vcx_command_handle_t command_handle, const char *message_status, const char *uids, const char *pw_dids, void(*cb)(vcx_command_handle_t xhandle, vcx_error_t err, const char *messages));

/** Retrieves single message from the agency by the given uid */
vcx_error_t vcx_download_message( vcx_command_handle_t command_handle, const char *uid, void(*cb)(vcx_command_handle_t xhandle, vcx_error_t err, const char *message));

/** Get Messages (Cloud Agent) of given status */
vcx_error_t vcx_download_agent_messages( vcx_command_handle_t command_handle, const char *message_status, const char *uids, void(*cb)(vcx_command_handle_t xhandle, vcx_error_t err, const char *messages));

/** Update Message status */
vcx_error_t vcx_messages_update_status( vcx_command_handle_t command_handle, const char *message_status, const char *msg_json, void(*cb)(vcx_command_handle_t xhandle, vcx_error_t err));

/** Fetch and Cache public entities from the Ledger associated with stored in the wallet credentials */
vcx_error_t vcx_fetch_public_entities( vcx_command_handle_t command_handle, void(*cb)(vcx_command_handle_t xhandle, vcx_error_t err));

/** Check the health of VCX and CAS */
vcx_error_t vcx_health_check( vcx_command_handle_t command_handle, void(*cb)(vcx_command_handle_t xhandle, vcx_error_t err));

/**
 * utils object
 */
vcx_error_t vcx_ledger_get_fees(vcx_command_handle_t command_handle, void(*cb)(vcx_command_handle_t xhandle, vcx_error_t error, const char *fees));

/**
 * logging
 **/
vcx_error_t vcx_set_default_logger(const char* pattern);

vcx_error_t vcx_set_logger( const void* context,
                            vcx_bool_t (*enabledFn)(const void*  context,
                                                      vcx_u32_t level,
                                                      const char* target),
                            void (*logFn)(const void*  context,
                                          vcx_u32_t level,
                                          const char* target,
                                          const char* message,
                                          const char* module_path,
                                          const char* file,
                                          vcx_u32_t line),
                            void (*flushFn)(const void*  context));

/// Retrieve author agreement set on the Ledger
///
/// #params
///
/// command_handle: command handle to map callback to user context.
///
/// cb: Callback that provides array of matching messages retrieved
///
/// #Returns
/// Error code as a u32
vcx_error_t vcx_get_ledger_author_agreement(vcx_u32_t command_handle,
                                            void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/// Set some accepted agreement as active.
///
/// As result of succesfull call of this funciton appropriate metadata will be appended to each write request by `indy_append_txn_author_agreement_meta_to_request` libindy call.
///
/// #Params
/// text and version - (optional) raw data about TAA from ledger.
///     These parameters should be passed together.
///     These parameters are required if hash parameter is ommited.
/// hash - (optional) hash on text and version. This parameter is required if text and version parameters are ommited.
/// acc_mech_type - mechanism how user has accepted the TAA
/// time_of_acceptance - UTC timestamp when user has accepted the TAA
///
/// #Returns
/// Error code as a u32
vcx_error_t vcx_set_active_txn_author_agreement_meta(const char *text, const char *version, const char *hash, const char *acc_mech_type, vcx_u64_t type_);

vcx_error_t vcx_wallet_backup_create(vcx_command_handle_t command_handle, const char *source_id, const char *backup_key,
              void (*cb)(vcx_command_handle_t, vcx_error_t, vcx_wallet_backup_handle_t));

/// Wallet Backup to the Cloud
vcx_error_t vcx_wallet_backup_backup(vcx_command_handle_t command_handle, vcx_wallet_backup_handle_t wallet_backup_handle, const char *path,
                                      void (*cb)(vcx_command_handle_t, vcx_error_t));

/// Checks for any state change and updates the the state attribute
vcx_error_t vcx_wallet_backup_update_state(vcx_command_handle_t command_handle, vcx_wallet_backup_handle_t wallet_backup_handle,
                                            void (*cb)(vcx_command_handle_t, vcx_error_t, vcx_state_t));

/// Checks the message any state change and updates the the state attribute
vcx_error_t vcx_wallet_backup_update_state_with_message(vcx_command_handle_t command_handle, vcx_wallet_backup_handle_t wallet_backup_handle, const char *message,
                                                        void (*cb)(vcx_command_handle_t, vcx_error_t, vcx_state_t));

/// Takes the wallet backup object and returns a json string of all its attributes
vcx_error_t vcx_wallet_backup_serialize(vcx_command_handle_t command_handle, vcx_wallet_backup_handle_t wallet_backup_handle,
                                        void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/// Takes a json string representing an wallet backup object and recreates an object matching the json
vcx_error_t vcx_wallet_backup_deserialize(vcx_command_handle_t command_handle, const char *wallet_backup_str,
                                          void (*cb)(vcx_command_handle_t, vcx_error_t, vcx_wallet_backup_handle_t));

/** Retrieve cloud backup and Import an encrypted file back into the wallet */
vcx_error_t vcx_wallet_backup_restore(vcx_command_handle_t handle, const char *config, void (*cb)(vcx_command_handle_t command_handle, vcx_error_t err));

/// Create pairwise agent which can be later used for connection establishing.
vcx_error_t vcx_create_pairwise_agent(vcx_command_handle_t command_handle,
                                      void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

// Get the credential request message that can be sent to the specified connection
//
// #params
// command_handle: command handle to map callback to user context
//
// credential_handle: credential handle that was provided during creation. Used to identify credential object
//
// my_pw_did: my pw did associated with person I'm sending credential to
//
// their_pw_did: their pw did associated with person I'm sending credential to
//
// cb: Callback that provides error status of credential request
//
// #Returns
// Error code as a u32
vcx_error_t vcx_credential_get_request_msg(vcx_command_handle_t command_handle,
                                           vcx_credential_handle_t credential_handle,
                                           const char *my_pw_did,
                                           const char *their_pw_did,
                                           vcx_payment_handle_t payment_handle,
                                           void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/// Get the information about the connection state.
///
/// Note: This method can be used for `aries` communication method only.
///     For other communication method it returns ActionNotSupported error.
///
/// #Params
/// command_handle: command handle to map callback to user context.
///
/// connection_handle: was provided during creation. Used to identify connection object
///
/// cb: Callback that provides the json string of connection information
///
/// # Example
/// info ->
///      {
///         "current": {
///             "did": <str>
///             "recipientKeys": array<str>
///             "routingKeys": array<str>
///             "serviceEndpoint": <str>,
///             "protocols": array<str> -  The set of protocol supported by current side.
///         },
///         "remote: { <Option> - details about remote connection side
///             "did": <str> - DID of remote side
///             "recipientKeys": array<str> - Recipient keys
///             "routingKeys": array<str> - Routing keys
///             "serviceEndpoint": <str> - Endpoint
///             "protocols": array<str> - The set of protocol supported by side. Is filled after DiscoveryFeatures process was completed.
///          }
///    }
///
/// #Returns
/// Error code as a u32
vcx_error_t vcx_connection_info(vcx_command_handle_t command_handle,
                                vcx_connection_handle_t connection_handle,
                                void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

// Takes the Connection object and returns callers their_pw_did associated with this connection
//
// #Params
// command_handle: command handle to map callback to user context.
//
// connection_handle: Connection handle that identifies pairwise connection
//
// #Returns
// Error code as a u32
vcx_error_t vcx_connection_get_their_pw_did(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

// Takes the Connection object and returns callers pw_did associated with this connection
//
// #Params
// command_handle: command handle to map callback to user context.
//
// connection_handle: Connection handle that identifies pairwise connection
//
// #Returns
// Error code as a u32
vcx_error_t vcx_connection_get_pw_did(vcx_command_handle_t command_handle, vcx_connection_handle_t connection_handle, void (*cb)(vcx_command_handle_t, vcx_error_t, const char*));

/// Send discovery features message to the specified connection to discover which features it supports, and to what extent.
///
/// Note that this function is useful in case `aries` communication method is used.
/// In other cases it returns ActionNotSupported error.
///
/// #params
///
/// command_handle: command handle to map callback to user context.
///
/// connection_handle: connection to send message
///
/// query: (Optional) query string to match against supported message types.
///
/// comment: (Optional) human-friendly description of the query.
///
/// cb: Callback that provides success or failure of request
///
/// #Returns
/// Error code as a u32
vcx_error_t vcx_connection_send_discovery_features(vcx_u32_t command_handle,
                                                   vcx_connection_handle_t connection_handle,
                                                   const char* query,
                                                   const char* comment,
                                                   void (*cb)(vcx_command_handle_t, vcx_error_t)
                                                   );

vcx_error_t indy_build_txn_author_agreement_request(vcx_u32_t handle,
                                                    const char* submitter_did,
                                                    const char* text_ctype,
                                                    const char* version_ctype,
                                                    void (*cb)(vcx_command_handle_t, vcx_error_t)
                                                   );

vcx_error_t vcx_set_log_max_lvl(vcx_u32_t handle, vcx_u32_t max_lvl, void (*cb)(vcx_command_handle_t, vcx_error_t));

vcx_error_t vcx_get_request_price(vcx_u32_t handle, const char* config_char, const char* requester_info_json_char);

/// Endorse transaction to the ledger preserving an original author
///
/// #params
///
/// command_handle: command handle to map callback to user context.
/// transaction: transaction to endorse
///
/// cb: Callback that provides array of matching messages retrieved
///
/// #Returns
/// Error code as a u32
vcx_error_t vcx_endorse_transaction(vcx_u32_t command_handle,
                                    const char* transaction,
                                    void (*cb)(vcx_command_handle_t, vcx_error_t)
                                   );

vcx_error_t indy_build_acceptance_mechanisms_request(vcx_u32_t command_handle,
                                                     const char* submitter_did,
                                                     const char* aml,
                                                     const char* version,
                                                     const char* aml_context,
                                                     void (*cb)(vcx_command_handle_t, vcx_error_t)
                                                     );

vcx_error_t indy_crypto_anon_decrypt(vcx_u32_t command_handle,
                                     vcx_wallet_backup_handle_t wallet_handle,
                                     const char* recipient_vk,
                                     uint8_t const* encrypted_msg,
                                     void (*cb)(vcx_command_handle_t, vcx_error_t)
                                    );

// Signs a message with a payment address.
//
// # Params:
// command_handle: command handle to map callback to user context.
// address: payment address of message signer. The key must be created by calling vcx_wallet_create_address
// message_raw: a pointer to first byte of message to be signed
// message_len: a message length
// cb: Callback that takes command result as parameter.
//
// # Returns:
// a signature string
vcx_error_t vcx_wallet_sign_with_address(vcx_command_handle_t command_handle,
                                         const char *payment_address,
                                         const unsigned short *message_raw,
                                         vcx_u32_t message_len,
                                         void (*cb)(vcx_command_handle_t, vcx_error_t, const unsigned short *, vcx_u32_t)
                                        );

// Verify a signature with a payment address.
//
// #Params
// command_handle: command handle to map callback to user context.
// address: payment address of the message signer
// message_raw: a pointer to first byte of message that has been signed
// message_len: a message length
// signature_raw: a pointer to first byte of signature to be verified
// signature_len: a signature length
// cb: Callback that takes command result as parameter.
//
// #Returns
// valid: true - if signature is valid, false - otherwise
vcx_error_t vcx_wallet_verify_with_address(vcx_command_handle_t command_handle,
                                           const char *payment_address,
                                           const unsigned short *message_raw,
                                           vcx_u32_t message_len,
                                           const unsigned short *signature_raw,
                                           vcx_u32_t signature_len,
                                           void (*cb)(vcx_command_handle_t, vcx_error_t, vcx_bool_t)
                                          );
/** For testing purposes only */
void vcx_set_next_agency_response(int);
#ifdef __cplusplus
}
#endif

#endif
