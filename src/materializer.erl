-module(materializer).
-include("floppy.hrl").

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").
-endif.

-export([create_snapshot/1,
	 update_snapshot/3]).

%% @doc	Creates an empty CRDT
%%	Input:	Type: The type of CRDT to create
%%	Output: The newly created CRDT 
-spec create_snapshot(Type::atom()) -> term().
create_snapshot(Type) ->
    Type:new().

%% @doc	Applies all the operations of a list to a CRDT.
%%	Input:	Type: The type of CRDT to create
%%		Snapshot: Current state of the CRDT
%%		Ops: The list of operations to apply
%%	Output: The CRDT after appliying the operations 
-spec update_snapshot(Type::atom(), Snapshot::term(), Ops::list()) -> term().
update_snapshot(_, Snapshot, []) ->
    Snapshot;
update_snapshot(Type, Snapshot, [Op|Rest]) ->
    {_,#operation{payload=Payload}}=Op,
    {OpParam, Actor}=Payload,
    io:format("OpParam: ~w, Actor: ~w and Snapshot: ~w~n",[OpParam, Actor, Snapshot]),	
    {ok, NewSnapshot}= Type:update(OpParam, Actor, Snapshot),
    update_snapshot(Type, NewSnapshot, Rest).
    
-ifdef(TEST).
    materializer_test()->
    	GCounter = create_snapshot(riak_dt_gcounter),
	?assertEqual(0,riak_dt_gcounter:value(GCounter)),
	Ops = [{1,#operation{payload={increment, actor1}}},{2,#operation{payload={increment, actor2}}},{3,#operation{payload={{increment, 3}, actor1}}},{4,#operation{payload={increment, actor3}}}],
	GCounter2 = update_snapshot(riak_dt_gcounter, GCounter, Ops),
	?assertEqual(6,riak_dt_gcounter:value(GCounter2)).
-endif.