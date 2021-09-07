if Meteor.isClient
    @picked_user_tags = new ReactiveArray []
    @picked_user_levels = new ReactiveArray []
    @picked_user_roles = new ReactiveArray []


    Router.route '/users', (->
        @render 'users'
        ), name:'users'


    Template.users.onCreated ->
        @autorun -> Meteor.subscribe 'picked_users', 
            picked_user_tags.array() 
            picked_user_levels.array()

    Template.users.helpers
        users: ->
            match = {}
            # unless 'admin' in Meteor.user().roles
            #     match.levels = $in:['member']
            if picked_user_tags.array().length > 0 then match.tags = $all: picked_user_tags.array()
            Meteor.users.find match,
                sort:points:-1
            # if Meteor.user()
            #     if 'admin' in Meteor.user().roles
            #         Meteor.users.find()
            #     else
            #         Meteor.users.find(
            #             # levels:$in:['l1']
            #             levels:$in:['member']
            #         )
            # else
            #     Meteor.users.find(
            #         levels:$in:['member']
            #     )
    Template.user_card.events
        'click .fly_right': (e,t)->
            $(e.currentTarget).closest('.card').transition('scale', 500)
            $(e.currentTarget).closest('.grid').transition('fly up', 500)



    Template.addtoset_user.helpers
        ats_class: ->
            if Template.parentData()["#{@value}"] in @key
                'blue'
            else
                ''

    Template.addtoset_user.events
        'click .toggle_value': ->
            Meteor.users.update Template.parentData(1)._id,
                $addToSet:
                    "#{@key}": @value




    Template.user_cloud.onCreated ->
        @autorun -> Meteor.subscribe('user_tags',
            picked_user_tags.array()
            picked_user_levels.array()
            picked_user_roles.array()
            Session.get('view_mode')
        )

    Template.user_cloud.helpers
        # all_tags: ->
        #     user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
        #     if 0 < user_count < 3 then User_tags.find { count: $lt: user_count } else User_tags.find()
        picked_user_tags: ->
            # model = 'event'
            picked_user_tags.array()
        all_levels: ->
            user_count = Meteor.users.find(_id:$ne:Meteor.userId()).count()
            if 0 < user_count < 3 then Results.find { model:'level', count: $lt: user_count } else Results.find(model:'level')
        picked_user_tags: ->
            # model = 'event'
            picked_user_tags.array()

        picked_user_levels: ->
            # model = 'event'
            picked_user_levels.array()


    Template.user_cloud.events
        'click .select_tag': -> picked_user_tags.push @name
        'click .unselect_tag': -> picked_user_tags.remove @valueOf()
        'click #clear_tags': -> picked_user_tags.clear()

        'click .select_level': -> picked_user_levels.push @name
        'click .unselect_level': -> picked_user_levels.remove @valueOf()
        'click #clear_levels': -> picked_user_levels.clear()



if Meteor.isServer
    Meteor.publish 'picked_users', (
        picked_user_tags
        picked_user_levels
        )->
        match = {}
        if picked_user_tags.length > 0 then match.tags = $all: picked_user_tags
        # if picked_user_levels.length > 0 then match.levels = $all: picked_user_levels
        Meteor.users.find match,
            sort:
                points:-1
            limit:20
        # if Meteor.user()
        #     if 'admin' in Meteor.user().roles
        #         Meteor.users.find()
        #     else
        #         Meteor.users.find(
        #             # levels:$in:['l1']
        #             roles:$in:['member']
        #         )
        # else
        #     Meteor.users.find(
        #         levels:$in:['member']
        #     )



    Meteor.publish 'user_tags', (
        picked_user_tags,
        picked_user_levels,
        view_mode
        limit
    )->
        self = @
        match = {}
        if picked_user_tags.length > 0 then match.tags = $all: picked_user_tags
        if picked_user_levels.length > 0 then match.levels = $all: picked_user_levels
        # match.model = 'item'
        # if view_mode is 'users'
        #     match.bought = $ne:true
        #     match._author_id = $ne: Meteor.userId()
        # if view_mode is 'bought'
        #     match.bought = true
        #     match.buyer_id = Meteor.userId()
        # if view_mode is 'selling'
        #     match.bought = $ne:true
        #     match._author_id = Meteor.userId()
        # if view_mode is 'sold'
        #     match.bought = true
        #     match._author_id = Meteor.userId()

        cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: "tags": 1 }
            { $unwind: "$tags" }
            { $group: _id: "$tags", count: $sum: 1 }
            { $match: _id: $nin: picked_user_tags }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]


        cloud.forEach (user_tag, i) ->
            self.added 'user_tags', Random.id(),
                name: user_tag.name
                count: user_tag.count
                index: i
    
    
        level_cloud = Meteor.users.aggregate [
            { $match: match }
            { $project: "levels": 1 }
            { $unwind: "$levels" }
            { $group: _id: "$levels", count: $sum: 1 }
            { $match: _id: $nin: picked_user_levels }
            { $sort: count: -1, _id: 1 }
            { $limit: 10 }
            { $project: _id: 0, name: '$_id', count: 1 }
            ]


        level_cloud.forEach (level_result, i) ->
            self.added 'level_results', Random.id(),
                name: level_result.name
                count: level_result.count
                index: i

        self.ready()