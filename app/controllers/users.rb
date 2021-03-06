class Netflam
  module Controller
    class Users < Netflam; end

    Users.define do
      on ":username" do |username|
        @user = User.find_by_username(username)

        unless @user.nil? || @user == 0
          on "settings" do
            # get /u/:username/settings
            # -------------------------------------------------------------- */
            on get do
              render("settings")
            end

            # post /u/:username/settings (email, username, password, realname)
            # -------------------------------------------------------------- */
            on post, param("email"), param("username"), param("password"), param("realname"), param("bio") do |email, username, password, realname, bio|
              session[:user].email = email
              session[:user].username = username
              session[:user].realname = realname
              session[:user].bio = bio

              if session[:user].valid? == false
                @errors = session[:user].errors.messages
                session[:user] = User.find(session[:user].id)
                render("settings")
              else
                session[:user].save
                render("settings")
              end
            end
          end


          # get /u/:username
          # ---------------------------------------------------------------- */
          on true do
            # get /u/:username?page=:page
            # -------------------------------------------------------------- */
            on param("page", true) do |page|
              @stories = @user.stories.recent
              @stories = Netflam::Pagination.page(@stories, page)

              render("profile")
            end

            # get /u/:username
            # -------------------------------------------------------------- */
            on true do
              @stories = @user.stories.recent
              @stories = Netflam::Pagination.page(@stories, 1)

              render("profile")
            end
          end
        end
      end
    end
  end
end