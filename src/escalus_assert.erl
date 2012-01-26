%%==============================================================================
%% Copyright 2010 Erlang Solutions Ltd.
%%
%% Licensed under the Apache License, Version 2.0 (the "License");
%% you may not use this file except in compliance with the License.
%% You may obtain a copy of the License at
%%
%% http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing, software
%% distributed under the License is distributed on an "AS IS" BASIS,
%% WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%% See the License for the specific language governing permissions and
%% limitations under the License.
%%==============================================================================

-module(escalus_assert).

-export([is_chat_message/2, 
         has_no_stanzas/1, 
         is_iq/2,
         is_presence_stanza/1,
         is_presence_type/2,
         is_presence_with_show/2,
         is_presence_with_status/2,
         is_presence_with_priority/2,
         is_stanza_from/2,
         is_roster_result/1,
         is_roster_result_set/1,
         is_roster_result_short/1,
         count_roster_items/2,
         roster_contains/2]).

-include("include/escalus.hrl").

%%---------------------------------------------------------------------
%% API functions
%%---------------------------------------------------------------------

is_chat_message(Msg, Stanza) when is_list(Msg) ->
    is_chat_message(list_to_binary(Msg), Stanza);
is_chat_message(Msg, Stanza) when is_binary(Msg) ->
    chat = exmpp_message:get_type(Stanza),
    Msg = exmpp_message:get_body(Stanza).

is_iq(Type, Stanza) ->
    Type = exmpp_iq:get_type(Stanza);
is_iq(none, _Stanza) ->
    {error, badtype}.

has_no_stanzas(Client) ->
    false = escalus_client:has_stanzas(Client).

is_presence_stanza(Stanza) ->
    "presence" = exmpp_xml:get_name_as_list(Stanza).

is_presence_type(Type, Presence) ->
    case Type of
        "available" ->
            none = exmpp_xml:get_attribute_as_list(Presence, <<"type">>, none);
        _ ->
            Type = exmpp_xml:get_attribute_as_list(Presence, <<"type">>, none)
    end.

is_presence_with_show(Show, Presence) ->
    Show = exmpp_xml:get_path(Presence, [{element, "show"},
                                       cdata_as_list]).

is_presence_with_status(Status, Presence) ->
    Status = exmpp_xml:get_path(Presence, [{element, "status"},
                                       cdata_as_list]).

is_presence_with_priority(Priority, Presence) ->
    Priority = exmpp_xml:get_path(Presence, [{element, "priority"},
                                       cdata_as_list]).
                
is_stanza_from(#client{jid=Jid}, Stanza) ->
    ExpectedJid = binary_to_list(Jid),
    ActualJid = exmpp_xml:get_attribute_as_list(Stanza, <<"from">>, none),
    true = lists:prefix(ExpectedJid, ActualJid).


is_roster_result(Stanza) ->
    "result" = exmpp_xml:get_attribute_as_list(Stanza, <<"type">>, none),
    Query = exmpp_xml:get_element(Stanza, "jabber:iq:roster", "query"),
    exmpp_xml:element_matches(Query, "query").

is_roster_result_set(Stanza) ->
    "set" = exmpp_xml:get_attribute_as_list(Stanza, <<"type">>, none).

is_roster_result_short(Stanza) ->
    "result" = exmpp_xml:get_attribute_as_list(Stanza, <<"type">>, none).

count_roster_items(Num, Stanza) ->
    Items =  exmpp_xml:get_child_elements(
               exmpp_xml:get_element(Stanza, "jabber:iq:roster", "query")),
    Num = length(Items).

roster_contains(#client{jid=Jid}, Stanza) ->
    ExpectedJid = binary_to_list(Jid),
    Items =  exmpp_xml:get_child_elements(exmpp_xml:get_element(Stanza,"query")),
    true = lists:foldl(fun(Item, Res) ->
                               ContactJid = exmpp_xml:get_attribute_as_list(Item, 
                                                                        <<"jid">>, 
                                                                        none),
                               case lists:prefix(ExpectedJid, ContactJid) of
                                   true ->
                                       true;
                                   _ ->
                                       Res
                               end
                       end, false, Items).



                            


