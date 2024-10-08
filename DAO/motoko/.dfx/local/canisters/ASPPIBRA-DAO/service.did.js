export const idlFactory = ({ IDL }) => {
  const List = IDL.Rec();
  const Tokens = IDL.Record({ 'amount_e8s' : IDL.Nat });
  const SystemParams = IDL.Record({
    'transfer_fee' : Tokens,
    'proposal_vote_threshold' : Tokens,
    'proposal_submission_deposit' : Tokens,
  });
  const Account = IDL.Record({ 'owner' : IDL.Principal, 'tokens' : Tokens });
  List.fill(IDL.Opt(IDL.Tuple(IDL.Principal, List)));
  const ProposalState = IDL.Variant({
    'open' : IDL.Null,
    'rejected' : IDL.Null,
    'executing' : IDL.Null,
    'accepted' : IDL.Null,
    'failed' : IDL.Text,
    'succeeded' : IDL.Null,
  });
  const ProposalPayload = IDL.Record({
    'method' : IDL.Text,
    'canister_id' : IDL.Principal,
    'message' : IDL.Vec(IDL.Nat8),
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'votes_no' : Tokens,
    'voters' : List,
    'state' : ProposalState,
    'timestamp' : IDL.Int,
    'proposer' : IDL.Principal,
    'votes_yes' : Tokens,
    'payload' : ProposalPayload,
  });
  const BasicDaoStableStorage = IDL.Record({
    'system_params' : SystemParams,
    'accounts' : IDL.Vec(Account),
    'proposals' : IDL.Vec(Proposal),
  });
  const Result_2 = IDL.Variant({ 'ok' : IDL.Nat, 'err' : IDL.Text });
  const TransferArgs = IDL.Record({ 'to' : IDL.Principal, 'amount' : Tokens });
  const Result_1 = IDL.Variant({ 'ok' : IDL.Null, 'err' : IDL.Text });
  const UpdateSystemParamsPayload = IDL.Record({
    'transfer_fee' : IDL.Opt(Tokens),
    'proposal_vote_threshold' : IDL.Opt(Tokens),
    'proposal_submission_deposit' : IDL.Opt(Tokens),
  });
  const Vote = IDL.Variant({ 'no' : IDL.Null, 'yes' : IDL.Null });
  const VoteArgs = IDL.Record({ 'vote' : Vote, 'proposal_id' : IDL.Nat });
  const Result = IDL.Variant({ 'ok' : ProposalState, 'err' : IDL.Text });
  const DAO = IDL.Service({
    'account_balance' : IDL.Func([], [Tokens], ['query']),
    'get_proposal' : IDL.Func([IDL.Nat], [IDL.Opt(Proposal)], ['query']),
    'get_system_params' : IDL.Func([], [SystemParams], ['query']),
    'list_accounts' : IDL.Func([], [IDL.Vec(Account)], ['query']),
    'list_proposals' : IDL.Func([], [IDL.Vec(Proposal)], ['query']),
    'submit_proposal' : IDL.Func([ProposalPayload], [Result_2], []),
    'transfer' : IDL.Func([TransferArgs], [Result_1], []),
    'update_system_params' : IDL.Func([UpdateSystemParamsPayload], [], []),
    'vote' : IDL.Func([VoteArgs], [Result], []),
  });
  return DAO;
};
export const init = ({ IDL }) => {
  const List = IDL.Rec();
  const Tokens = IDL.Record({ 'amount_e8s' : IDL.Nat });
  const SystemParams = IDL.Record({
    'transfer_fee' : Tokens,
    'proposal_vote_threshold' : Tokens,
    'proposal_submission_deposit' : Tokens,
  });
  const Account = IDL.Record({ 'owner' : IDL.Principal, 'tokens' : Tokens });
  List.fill(IDL.Opt(IDL.Tuple(IDL.Principal, List)));
  const ProposalState = IDL.Variant({
    'open' : IDL.Null,
    'rejected' : IDL.Null,
    'executing' : IDL.Null,
    'accepted' : IDL.Null,
    'failed' : IDL.Text,
    'succeeded' : IDL.Null,
  });
  const ProposalPayload = IDL.Record({
    'method' : IDL.Text,
    'canister_id' : IDL.Principal,
    'message' : IDL.Vec(IDL.Nat8),
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'votes_no' : Tokens,
    'voters' : List,
    'state' : ProposalState,
    'timestamp' : IDL.Int,
    'proposer' : IDL.Principal,
    'votes_yes' : Tokens,
    'payload' : ProposalPayload,
  });
  const BasicDaoStableStorage = IDL.Record({
    'system_params' : SystemParams,
    'accounts' : IDL.Vec(Account),
    'proposals' : IDL.Vec(Proposal),
  });
  return [BasicDaoStableStorage];
};
