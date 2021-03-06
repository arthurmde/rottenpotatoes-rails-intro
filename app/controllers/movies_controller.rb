class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if (session[:sort] && !params[:sort])
      flash.keep
      sort = session[:sort]      
      session[:sort] = nil
      params[:sort] = sort
      redirect_to movies_path(params)
    elsif(session[:ratings] && !params[:ratings])
      flash.keep
      ratings = session[:ratings]
      session[:ratings] = nil
      params[:ratings] = ratings if ratings
      params[:commit] = "Refresh"
      redirect_to movies_path(params)
    else
      sort_param = params[:sort]
      @class_name = sort_param
      @all_ratings = Movie.ratings
      @checked_ratings = @all_ratings
      @movies = Movie.all 

      if(params["commit"] == "Refresh" && params["ratings"])
        puts "#"*100
        session[:ratings] = params["ratings"]
        @checked_ratings = params["ratings"].keys
      end

      @movies = @movies.where("rating IN (?)", @checked_ratings)
      @movies = @movies.order(sort_param)
      session[:sort] = sort_param
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
