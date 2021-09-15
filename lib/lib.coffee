@Docs = new Meteor.Collection 'docs'
@Results = new Meteor.Collection 'results'

# Docs.before.insert (userId, doc)->


if Meteor.isClient
    # console.log $
    $.cloudinary.config
        cloud_name:"facet"

if Meteor.isServer
    Cloudinary.config
        cloud_name: 'facet'
        api_key: Meteor.settings.cloudinary_key
        api_secret: Meteor.settings.cloudinary_secret




# Docs.after.insert (userId, doc)->
#     console.log doc.tags
#     return

# Docs.after.update ((userId, doc, fieldNames, modifier, options) ->
#     doc.tag_count = doc.tags?.length
#     # Meteor.call 'generate_authored_cloud'
# ), fetchPrevious: true




Docs.helpers
    author: -> Meteor.users.findOne @_author_id
    _author: -> Meteor.users.findOne @_author_id
    _buyer: -> Meteor.users.findOne @buyer_id
    target_user: ->
        Meteor.users.findOne @target_id
    
    when: -> moment(@_timestamp).fromNow()
    is_visible: -> @published in [0,1]
    is_published: -> @published is 1
    is_anonymous: -> @published is 0
    is_private: -> @published is -1
    is_read: ->
        @read_ids and Meteor.userId() in @read_ids

    enabled_features: () ->
        Docs.find
            model:'feature'
            _id:$in:@enabled_feature_ids



# Meteor.users.helpers
#     name: ->
#         if @display_name
#             "#{@display_name}"
#         else if @first_name and @last_name
#             "#{@first_name} #{@last_name}"
#         else
#             "#{@username}"
#     is_current_member: ->
#         if @roles
#             if 'admin' in @roles
#                 if 'member' in @current_roles then true else false
#             else
#                 if 'member' in @roles then true else false

#     email_address: -> if @emails and @emails[0] then @emails[0].address
#     email_verified: -> if @emails and @emails[0] then @emails[0].verified
#     five_tags: -> if @tags then @tags[..4]
#     three_tags: -> if @tags then @tags[..2]
#     last_name_initial: -> if @last_name then @last_name.charAt 0
 
 
    
Meteor.methods
    upvote: (doc)->
        if Meteor.userId()
            if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull:
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $addToSet: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $inc:
                        points:2
                        upvotes:1
                        downvotes:-1
            else if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $inc:
                        points:-1
                        upvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $inc:
                        upvotes:1
                        points:1
            Meteor.users.update doc._author_id,
                $inc:karma:1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:1
                    anon_upvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:1

    downvote: (doc)->
        if Meteor.userId()
            if doc.upvoter_ids and Meteor.userId() in doc.upvoter_ids
                Docs.update doc._id,
                    $pull: 
                        upvoter_ids:Meteor.userId()
                        upvoter_usernames:Meteor.user().username
                    $addToSet: 
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $inc:
                        points:-2
                        downvotes:1
                        upvotes:-1
            else if doc.downvoter_ids and Meteor.userId() in doc.downvoter_ids
                Docs.update doc._id,
                    $pull: 
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $inc:
                        points:1
                        downvotes:-1
            else
                Docs.update doc._id,
                    $addToSet: 
                        downvoter_ids:Meteor.userId()
                        downvoter_usernames:Meteor.user().username
                    $inc:
                        points:-1
                        downvotes:1
            Meteor.users.update doc._author_id,
                $inc:karma:-1
        else
            Docs.update doc._id,
                $inc:
                    anon_points:-1
                    anon_downvotes:1
            Meteor.users.update doc._author_id,
                $inc:anon_karma:-1

# force_loggedin =  ()->
#     if !Meteor.userId()
#         @render 'login'
#     else
#         @next()

# Router.onBeforeAction(force_loggedin, {
#   # only: ['admin']
#   # except: ['register', 'forgot_password','reset_password','front','delta','doc_view','verify-email']
#   except: [
#     'login'
#     'register'
#     # 'users'
#     # 'services'
#     # 'service_view'
#     # 'products'
#     # 'product_view'
#     # 'rentals'
#     # 'rental_view'
#     # 'home'
#     # 'forgot_password'
#     # 'reset_password'
#     # 'user_orders'
#     # 'user_food'
#     # 'user_finance'
#     # 'user_dashboard'
#     # 'verify-email'
#     # 'food_view'
#   ]
# });


# Router.route('enroll', {
#     path: '/enroll-account/:token'
#     template: 'reset_password'
#     onBeforeAction: ()=>
#         Meteor.logout()
#         Session.set('_resetPasswordToken', this.params.token)
#         @subscribe('enrolledUser', this.params.token).wait()
# })



Meteor.methods
    add_facet_filter: (delta_id, key, filter)->
        if key is '_keys'
            new_facet_ob = {
                key:filter
                filters:[]
                res:[]
            }
            Docs.update { _id:delta_id },
                $addToSet: facets: new_facet_ob
        Docs.update { _id:delta_id, "facets.key":key},
            $addToSet: "facets.$.filters": filter

        Meteor.call 'fum', delta_id, (err,res)->


    remove_facet_filter: (delta_id, key, filter)->
        if key is '_keys'
            Docs.update { _id:delta_id },
                $pull:facets: {key:filter}
        Docs.update { _id:delta_id, "facets.key":key},
            $pull: "facets.$.filters": filter
        Meteor.call 'fum', delta_id, (err,res)->



    upvote_sentence: (doc_id, sentence)->
        # console.log sentence
        if sentence.weight
            Docs.update(
                { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
                $inc: 
                    "tone.result.sentences_tone.$.weight": 1
                    points:1
            )
        else
            Docs.update(
                { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
                {
                    $set: 
                        "tone.result.sentences_tone.$.weight": 1
                    $inc:
                        points:1
                }
            )
    tag_sentence: (doc_id, sentence, tag)->
        # console.log sentence
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { $addToSet: 
                "tone.result.sentences_tone.$.tags": tag
                "tags": tag
            }
        )

    reset_sentence: (doc_id, sentence)->
        # console.log sentence
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { 
                $set: 
                    "tone.result.sentences_tone.$.weight": -2
            } 
        )


    downvote_sentence: (doc_id, sentence)->
        # console.log sentence
        Docs.update(
            { _id:doc_id, "tone.result.sentences_tone.sentence_id": sentence.sentence_id },
            { $inc: 
                "tone.result.sentences_tone.$.weight": -1
                points: -1
            }
        )
    check_url: (str)->
        # console.log 'testing', str
        pattern = new RegExp('^(https?:\\/\\/)?'+ # protocol
        '((([a-z\\d]([a-z\\d-]*[a-z\\d])*)\\.)+[a-z]{2,}|'+ # domain name
        '((\\d{1,3}\\.){3}\\d{1,3}))'+ # OR ip (v4) address
        '(\\:\\d+)?(\\/[-a-z\\d%_.~+]*)*'+ # port and path
        '(\\?[;&a-z\\d%_.~+=-]*)?'+ # query string
        '(\\#[-a-z\\d_]*)?$','i') # fragment locator
        return !!pattern.test(str)
