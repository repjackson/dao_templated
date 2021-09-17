if Meteor.isClient
    Template.registerHelper 'nl2br', (text)->
        nl2br = (text + '').replace(/([^>\r\n]?)(\r\n|\n\r|\r|\n)/g, '$1' + '<br>' + '$2')
        new Spacebars.SafeString(nl2br)
    
    
    Template.registerHelper 'delta_key_value_is', (key, value) ->
        # console.log 'key', key
        delta = Docs.findOne model:'delta'
        # console.log 'value', value
        if delta
            delta["#{key}"] is value
        
        
    Template.registerHelper 'fixed', (input) ->
        if input
            input.toFixed(2)
            
            
    Template.registerHelper 'sortable_fields', () ->
        model = Docs.findOne
            model:'model'
            slug:Router.current().params.model_slug
        if model
            Docs.find {
                model:'field'
                parent_id:model._id
                sortable:true
            }, sort:rank:1


    Template.registerHelper 'current_delta', () -> Docs.findOne model:'delta'
    Template.registerHelper 'view_template', ->
        # console.log 'view template this', @
        field_type_doc =
            Docs.findOne
                model:'field_type'
                _id: @field_type_id
        # console.log 'field type doc', field_type_doc
        "#{field_type_doc.slug}_view"


    Template.registerHelper 'edit_template', ->
        field_type_doc =
            Docs.findOne
                model:'field_type'
                _id: @field_type_id

        # console.log 'field type doc', field_type_doc
        "#{field_type_doc.slug}_edit"


    Template.registerHelper 'fields', () ->
        model = Docs.findOne
            model:'model'
            slug:Router.current().params.model_slug
        if model
            match = {}
            # if Meteor.user()
            #     match.view_roles = $in:Meteor.user().roles
            match.model = 'field'
            match.parent_id = model._id
            # console.log model
            cur = Docs.find match,
                sort:rank:1
            # console.log cur.fetch()
            cur

    Template.registerHelper 'edit_fields', () ->
        console.log 'finding edit fields'
        model = Docs.findOne
            model:'model'
            slug:Router.current().params.model_slug
        if model
            Docs.find {
                model:'field'
                parent_id:model._id
                # edit_roles:$in:Meteor.user().roles
            }, sort:rank:1


    Template.registerHelper 'view_template', -> "#{@field_type}_view"
    Template.registerHelper 'edit_template', -> "#{@field_type}_edit"

    Template.registerHelper 'current_model', ->
        Docs.findOne
            model:'model'
            slug: Router.current().params.model_slug

    Template.registerHelper 'is_loading', () ->
        Session.get('loading')
    Template.registerHelper 'field_value', () ->
        # console.log @
        parent = Template.parentData()
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)


        if @direct
            parent = Template.parentData()
        else if parent5
            if parent5._id
                parent = Template.parentData(5)
        else if parent6
            if parent6._id
                parent = Template.parentData(6)
        # console.log 'parent', parent
        if parent
            parent["#{@key}"]


    Template.registerHelper 'sorted_field_values', () ->
        # console.log @
        parent = Template.parentData()
        parent5 = Template.parentData(5)
        parent6 = Template.parentData(6)


        if @direct
            parent = Template.parentData()
        else if parent5._id
            parent = Template.parentData(5)
        else if parent6._id
            parent = Template.parentData(6)
        if parent
            _.sortBy parent["#{@key}"], 'number'


    # Router.route '/m/:model_slug', (->
    #     @render 'delta'
    #     ), name:'delta'

    Template.home.onCreated ->
        @autorun -> Meteor.subscribe 'query', Session.get('query'), ->
        @autorun -> Meteor.subscribe 'tags', Session.get('query'), ->
    # Template.delta.onCreated ->
        # @autorun -> Meteor.subscribe 'model_from_slug', Router.current().params.model_slug
        # @autorun -> Meteor.subscribe 'model_fields_from_slug', Router.current().params.model_slug
        # @autorun -> Meteor.subscribe 'my_delta'

        # Session.set 'loading', true
        # Meteor.call 'set_facets', Router.current().params.model_slug, ->
        #     Session.set 'loading', false
    # Template.delta.onRendered ->
    #     Meteor.call 'log_view', @_id, ->

    Template.home.helpers
        results: ->
            Docs.find 
                title: {$regex:Session.get('query'), $options:'i'}
        result_tags: ->
            Results.find {} 
                # title: {$regex:Session.get('query'), $options:'i'}

        picked_tags: -> picked_tags.array()

    Template.home.events
        'click .toggle_sort_column': ->
            console.log @
            delta = Docs.findOne model:'delta'
            console.log delta



        'click .clear_query': ->
            # console.log @
            delta = Docs.findOne model:'delta'
            Docs.update delta._id,
                $unset:search_query:1
            Session.set 'loading', true
            Meteor.call 'fum', delta._id, ->
                Session.set 'loading', false

        # 'click .page_up': (e,t)->
        #     delta = Docs.findOne model:'delta'
        #     Docs.update delta._id,
        #         $inc: current_page:1
        #     Session.set 'is_calculating', true
        #     Meteor.call 'fo', (err,res)->
        #         if err then console.log err
        #         else
        #             Session.set 'is_calculating', false
        #
        # 'click .page_down': (e,t)->
        #     delta = Docs.findOne model:'delta'
        #     Docs.update delta._id,
        #         $inc: current_page:-1
        #     Session.set 'is_calculating', true
        #     Meteor.call 'fo', (err,res)->
        #         if err then console.log err
        #         else
        #             Session.set 'is_calculating', false

        # 'click .select_tag': -> picked_tags.push @name
        # 'click .unselect_tag': -> picked_tags.remove @valueOf()
        # 'click #clear_tags': -> picked_tags.clear()
        #
        # 'keyup #search': (e)->
            # switch e.which
            #     when 13
            #         if e.target.value is 'clear'
            #             picked_tags.clear()
            #             $('#search').val('')
            #         else
            #             picked_tags.push e.target.value.toLowerCase().trim()
            #             $('#search').val('')
            #     when 8
            #         if e.target.value is ''
            #             picked_tags.pop()
        'keyup #search': _.throttle((e,t)->
            query = $('#search').val()
            Session.set('query', query)
            # delta = Docs.findOne model:'delta'
            # Docs.update delta._id,
            #     $set:search_query:query
            # Session.set 'loading', true
            # Meteor.call 'fum', delta._id, ->
            #     Session.set 'loading', false

            # console.log Session.get('current_query')
            if e.which is 13
                search = $('#search').val().trim().toLowerCase()
                if search.length > 0
                    picked_tags.push search
                    console.log 'search', search
                    # Meteor.call 'log_term', search, ->
                    $('#search').val('')
                    Session.set('current_query', null)
                    # # $('#search').val('').blur()
                    # # $( "p" ).blur();
                    # Meteor.setTimeout ->
                    #     Session.set('dummy', !Session.get('dummy'))
                    # , 10000
        , 1000)






    # Template.facet.onCreated ->
    #     @viewing_facet = new ReactiveVar true
    
    # Template.facet.onRendered ->
    #     Meteor.setTimeout ->
    #         $('.accordion').accordion()
    #     , 1500

    # Template.facet.events
    #     # 'click .ui.accordion': ->
    #     #     $('.accordion').accordion()
    #     'click .toggle_view_facet': (e,t)->
    #         t.viewing_facet.set !t.viewing_facet.get()

    #     'click .toggle_selection': ->
    #         delta = Docs.findOne model:'delta'
    #         facet = Template.currentData()

    #         Session.set 'loading', true
    #         if facet.filters and @name in facet.filters
    #             Meteor.call 'remove_facet_filter', delta._id, facet.key, @name, ->
    #                 Session.set 'loading', false
    #         else
    #             Meteor.call 'add_facet_filter', delta._id, facet.key, @name, ->
    #                 Session.set 'loading', false

    #     'keyup .add_filter': (e,t)->
    #         # console.log @
    #         if e.which is 13
    #             delta = Docs.findOne model:'delta'
    #             facet = Template.currentData()
    #             if @field_type is 'number'
    #                 filter = parseInt t.$('.add_filter').val()
    #             else
    #                 filter = t.$('.add_filter').val()
    #             Session.set 'loading', true
    #             Meteor.call 'add_facet_filter', delta._id, facet.key, filter, ->
    #                 Session.set 'loading', false
    #             t.$('.add_filter').val('')




    # Template.facet.helpers
    #     viewing_results: ->
    #         Template.instance().viewing_facet.get()
    #     filtering_res: ->
    #         delta = Docs.findOne model:'delta'
    #         filtering_res = []
    #         if @key is '_keys'
    #             @res
    #         else
    #             for filter in @res
    #                 if filter.count < delta.total
    #                     filtering_res.push filter
    #                 else if filter.name in @filters
    #                     filtering_res.push filter
    #             filtering_res
    #     toggle_value_class: ->
    #         facet = Template.parentData()
    #         delta = Docs.findOne model:'delta'
    #         if Session.equals 'loading', true
    #              'disabled basic'
    #         else if facet.filters.length > 0 and @name in facet.filters
    #             'active'
    #         else ''

