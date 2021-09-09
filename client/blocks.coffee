Template.session_edit_button.events
    'click .save_this': ->
        Session.set('editing_id', null)
    'click .edit_this': ->
        Session.set('editing_id', @_id)
    
Template.session_edit_button.helpers







Template.session_toggle.events
    'click .toggle_session_var': ->
        Session.set(@key, !Session.get(@key))
        $('body').toast(
            showIcon: 'toggle on'
            message: "#{@key} #{Session.get(@key)}"
            showProgress: 'bottom'
            # class: 'success'
            # displayTime: 'auto',
            position: "bottom right"
        )

Template.session_toggle.helpers
    session_toggle_class: ->
        if Session.get(@key) then 'blue' else 'basic'

Template.session_set.events
    'click .set_value': ->
        if Session.equals(@key, @value)
            Session.set(@key, null)
        else
            Session.set(@key, @value)
Template.session_set.helpers
    session_set_class: ->
        if Session.equals(@key,@value) then 'active large' else 'basic'
Template.print_this.events
    'click .print': -> console.log @
Template.alert_this.events
    'click .alert': -> alert @valueOf()

Template.search_input.events
    'click .clear_query': -> 
        Session.set("#{@model}_#{@field}_filter", null)

    'keyup .search_field': (e,t)->
        if e.which is 27
            Session.set("#{@model}_#{@field}_filter", null)
            $('.search_field').val('')
        else 
            val = $('.search_field').val()
            Session.set("#{@model}_#{@field}_filter", val)
        
Template.search_input.helpers
    current_filter: ->
        Session.get("#{@model}_#{@field}_filter")


Template.comments.onRendered ->
    # Meteor.setTimeout ->
    #     $('.accordion').accordion()
    # , 1000
Template.comments.onCreated ->
    # parent = Docs.findOne Template.parentData()._id
    parent = Docs.findOne Router.current().params.doc_id
    @autorun => Meteor.subscribe 'comments', parent._id
    # if parent
Template.comments.helpers
    doc_comments: ->
        parent = Docs.findOne Router.current().params.doc_id
        # parent = Docs.findOne Template.parentData()._id
        Docs.find
            parent_id:parent._id
            model:'comment'
Template.comments.events
    'keyup .add_comment': (e,t)->
        if e.which is 13
            # parent = Docs.findOne Template.parentData()._id
            parent = Docs.findOne Router.current().params.doc_id
            comment = t.$('.add_comment').val()
            Docs.insert
                parent_id: parent._id
                model:'comment'
                parent_model:parent.model
                body:comment
            t.$('.add_comment').val('')

    'click .remove_comment': ->
        if confirm 'Confirm remove comment'
            Docs.remove @_id

Template.voting.events
    'click .upvote': (e,t)->
        $(e.currentTarget).closest('.button').transition('pulse',200)
        Meteor.call 'upvote', @
    'click .downvote': (e,t)->
        $(e.currentTarget).closest('.button').transition('pulse',200)
        Meteor.call 'downvote', @


Template.voting_small.events
    'click .upvote': (e,t)->
        $(e.currentTarget).closest('.button').transition('pulse',200)
        Meteor.call 'upvote', @
    'click .downvote': (e,t)->
        $(e.currentTarget).closest('.button').transition('pulse',200)
        Meteor.call 'downvote', @



# Template.doc_card.onCreated ->
#     @autorun => Meteor.subscribe 'doc', Template.currentData().doc_id
# Template.doc_card.helpers
#     doc: ->
#         Docs.findOne
#             _id:Template.currentData().doc_id





# Template.call_watson.events
#     'click .autotag': ->
#         doc = Docs.findOne Router.current().params.doc_id
#
#         Meteor.call 'call_watson', doc._id, @key, @mode

Template.voting_full.helpers
    upvote_class: ->
        if @upvoter_ids and Meteor.userId() in @upvoter_ids
            'green' 
        else
            'outline'
    downvote_class: ->
        if @downvoter_ids and Meteor.userId() in @downvoter_ids
            'red' 
        else 
            'outline'
Template.voting_full.events
    'click .upvote': (e,t)->
        $(e.currentTarget).closest('.button').transition('pulse',200)
        Meteor.call 'upvote', @
    'click .downvote': (e,t)->
        $(e.currentTarget).closest('.button').transition('pulse',200)
        Meteor.call 'downvote', @







Template.username_info.onCreated ->
    @autorun => Meteor.subscribe 'user_from_username', @data
Template.username_info.events
    'click .goto_profile': ->
        user = Meteor.users.findOne username:@valueOf()
        if user.is_current_member
            Router.go "/member/#{user.username}/"
        else
            Router.go "/user/#{user.username}/"
Template.username_info.helpers
    user: -> Meteor.users.findOne username:@valueOf()




# Template.user_info.onCreated ->
#     @autorun => Meteor.subscribe 'user_from_id', @data
# Template.user_info.helpers
#     user: -> Meteor.users.findOne @valueOf()


Template.toggle_edit.events
    'click .toggle_edit': ->




Template.user_list_info.onCreated ->
    @autorun => Meteor.subscribe 'user', @data

Template.user_list_info.helpers
    user: ->
        Meteor.users.findOne @valueOf()



# Template.user_field.helpers
#     key_value: ->
#         user = Meteor.users.findOne Router.current().params.doc_id
#         user["#{@key}"]

# Template.user_field.events
#     'blur .user_field': (e,t)->
#         value = t.$('.user_field').val()
#         Meteor.users.update Router.current().params.doc_id,
#             $set:"#{@key}":value



Template.user_list_toggle.onCreated ->
    @autorun => Meteor.subscribe 'user_list', Template.parentData(),@key
Template.user_list_toggle.events
    'click .toggle': (e,t)->
        parent = Template.parentData()
        $(e.currentTarget).closest('.button').transition('pulse',200)
        if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"]
            Docs.update parent._id,
                $pull:"#{@key}":Meteor.userId()
        else
            Docs.update parent._id,
                $addToSet:"#{@key}":Meteor.userId()
Template.user_list_toggle.helpers
    user_list_toggle_class: ->
        if Meteor.user()
            parent = Template.parentData()
            if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then '' else 'basic'
        else
            'disabled'
    in_list: ->
        parent = Template.parentData()
        if parent["#{@key}"] and Meteor.userId() in parent["#{@key}"] then true else false
    list_users: ->
        parent = Template.parentData()
        Meteor.users.find _id:$in:parent["#{@key}"]




Template.viewing.events
    'click .mark_read': (e,t)->
        Docs.update @_id,
            $inc:views:1
        unless @read_ids and Meteor.userId() in @read_ids
            Meteor.call 'mark_read', @_id, ->
                # $(e.currentTarget).closest('.comment').transition('pulse')
                $('.unread_icon').transition('pulse')
    'click .mark_unread': (e,t)->
        Docs.update @_id,
            $inc:views:-1
        Meteor.call 'mark_unread', @_id, ->
            # $(e.currentTarget).closest('.comment').transition('pulse')
            $('.unread_icon').transition('pulse')
Template.viewing.helpers
    viewed_by: -> Meteor.userId() in @read_ids
    readers: ->
        readers = []
        if @read_ids
            for reader_id in @read_ids
                unless reader_id is @author_id
                    readers.push Meteor.users.findOne reader_id
        readers






Template.remove_button.events
    'click .remove_doc': (e,t)->
        if confirm "remove transfer?"
            Docs.remove @_id
            Router.go "/user/#{Meteor.user().username}"

Template.remove_icon.events
    'click .remove_doc': (e,t)->
        if confirm "remove #{@model}?"
            if $(e.currentTarget).closest('.card')
                $(e.currentTarget).closest('.card').transition('fly right', 1000)
            else
                $(e.currentTarget).closest('.segment').transition('fly right', 1000)
                $(e.currentTarget).closest('.item').transition('fly right', 1000)
                $(e.currentTarget).closest('.content').transition('fly right', 1000)
                $(e.currentTarget).closest('tr').transition('fly right', 1000)
                $(e.currentTarget).closest('.event').transition('fly right', 1000)
            Meteor.setTimeout =>
                Docs.remove @_id
            , 1000


Template.add_model_button.events
    'click .add': ->
        new_id = Docs.insert model: @model
        Router.go "/edit/#{new_id}"

Template.view_user_button.events
    'click .view_user': ->
        Router.go "/user/#{username}"


Template.session_edit_value_button.events
    'click .set_session_value': ->
        Session.set(@key, @value)

Template.session_edit_value_button.helpers
    calculated_class: ->
        res = ''
        if @cl
            res += @cl
        if Session.equals(@key,@value)
            res += ' blue'
        res



Template.session_boolean_toggle.events
    'click .toggle_session_key': ->
        Session.set(@key, !Session.get(@key))

Template.session_boolean_toggle.helpers
    calculated_class: ->
        res = ''
        if @cl
            res += @cl
        if Session.get(@key)
            res += ' blue'
        else
            res += ' basic'

        res

Template.doc_array_toggle.helpers
    doc_array_toggle_class: ->
        parent = Template.parentData()
        # user = Meteor.users.findOne Router.current().params.username
        if parent["#{@key}"] and @value in parent["#{@key}"] then 'blue' else 'basic'
Template.doc_array_toggle.events
    'click .toggle': (e,t)->
        parent = Template.parentData()
        if parent["#{@key}"]
            if @value in parent["#{@key}"]
                Docs.update parent._id,
                    $pull: "#{@key}":@value
            else
                Docs.update parent._id,
                    $addToSet: "#{@key}":@value
        else
            Docs.update parent._id,
                $addToSet: "#{@key}":@value


# Template.friend_finder.onCreated ->
#     @user_results = new ReblueVar
# Template.friend_finder.helpers
#     user_results: ->Template.instance().user_results.get()
# Template.friend_finder.events
#     'click .clear_results': (e,t)->
#         t.user_results.set null

#     'keyup .find_friend': (e,t)->
#         search_value = $(e.currentTarget).closest('.find_friend').val().trim()
#         if search_value.length > 1
#             Meteor.call 'lookup_user', search_value, @role_filter, (err,res)=>
#                 if err then console.error err
#                 else
#                     t.user_results.set res

#     'click .select_user': (e,t) ->
#         page_doc = Docs.findOne Router.current().params.doc_id
#         field = Template.currentData()



#         val = t.$('.edit_text').val()
#         if field.direct
#             parent = Template.parentData()
#         else
#             parent = Template.parentData(5)

#         doc = Docs.findOne parent._id
#         if doc
#             Docs.update parent._id,
#                 $set:"#{field.key}":@_id
#         else
#             Meteor.users.update parent._id,
#                 $set:"#{field.key}":@_id
            
#         t.user_results.set null
#         $('.find_friend').val ''
#         # Docs.update page_doc._id,
#         #     $set: assignment_timestamp:Date.now()

#     'click .pull_user': ->
#         if confirm "remove #{@username}?"
#             parent = Template.parentData(1)
#             field = Template.currentData()
#             doc = Docs.findOne parent._id
#             if doc
#                 Docs.update parent._id,
#                     $unset:"#{field.key}":1
#             else
#                 Meteor.users.update parent._id,
#                     $unset:"#{field.key}":1

#         #     page_doc = Docs.findOne Router.current().params.doc_id
#             # Meteor.call 'unassign_user', page_doc._id, @


Template.key_value_edit.events
    'click .set_key_value': ->
        parent = Template.parentData()
        # parent = Docs.findOne Router.current().params.doc_id
        Docs.update parent._id,
            $set: "#{@key}": @value

Template.key_value_edit.helpers
    set_key_value_class: ->
        # parent = Docs.findOne Router.current().params.doc_id
        parent = Template.parentData()
        if parent["#{@key}"] is @value then 'active' else 'basic'

Template.user_key_value_edit.events
    'click .set_key_value': ->
        parent = Template.parentData()
        # parent = Docs.findOne Router.current().params.doc_id
        Meteor.users.update parent._id,
            $set: "#{@key}": @value

Template.user_key_value_edit.helpers
    set_key_value_class: ->
        # parent = Docs.findOne Router.current().params.doc_id
        parent = Template.parentData()
        if parent["#{@key}"] is @value then 'active' else 'basic'
