if Meteor.isClient
    Template.tag_picker.onCreated ->
        @autorun => @subscribe 'wiki_doc', @data, ->
    Template.home.onCreated ->
        @autorun => @subscribe 'post_docs',
            picked_tags.array()
            Session.get('title_filter')

        @autorun => @subscribe 'post_facets',
            picked_tags.array()
            Session.get('title_filter')

    Template.tag_picker.events
        'click .pick_tag': -> 
            picked_tags.push @title
            Meteor.call 'call_wiki', @title,=>
                console.log 'called wiki on', @title
    Template.home.events
        'click .unpick_tag': -> picked_tags.remove @valueOf()

    Template.tag_picker.helpers
        wiki_doc_flat: ->
            # console.log @valueOf()
            Docs.findOne 
                model:'wikipedia'
                title:@valueOf()
        wiki_doc: ->
            # console.log @valueOf()
            Docs.findOne 
                model:'wikipedia'
                title:@title
                
    Template.home.helpers        
        picked_tags: -> picked_tags.array()
    
        # post_docs: ->
        #     Docs.find 
        #         model:'post'
        tag_results: ->
            doc_count = Docs.find({model:'post'}).count()
            # console.log 'count', doc_count
            if doc_count > 1
                Results.find {
                    count:$lt:doc_count
                    model:'post_tag'
                }, sort:_timestamp:-1
            else
                Results.find {
                    model:'post_tag'
                }, sort:_timestamp:-1
  
                
        
        current_post: ->
            Docs.findOne
                _id:Session.get('viewing_post_id')
                
        home_items: ->
            Docs.find {
                model:'post'
            }, sort:_timestamp:-1
                
    Template.home_item.helpers
        card_class: ->
            if Session.equals('viewing_post_id', @_id) then 'inverted large' else 'small basic' 
        is_selected: ->
            Session.equals('viewing_post_id', @_id)
    Template.home_item.events
        'click .view_item': ->
            Session.set('viewing_post_id', @_id)
            Docs.update @_id, 
                $inc:views:1
    Template.home.events
        'click .add_post': ->
            new_id = Docs.insert 
                model:'post'
            Router.go "/post/#{new_id}/edit"    
    