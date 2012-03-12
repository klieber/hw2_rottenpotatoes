class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    options = Hash.new
    if !params[:sort].blank?
      options[:order] = "#{params[:sort]} ASC" 
      @sort = params[:sort]
    elsif !session[:sort].blank?
      params[:sort] = session[:sort]
      options[:order] = "#{params[:sort]} ASC" 
      @sort = params[:sort]
      redirect = true
    end 
    @ratings = Hash.new
    if (params[:ratings])
      @ratings = params[:ratings]
      options[:conditions] = ["rating IN (?)",@ratings.keys]
    elsif (session[:ratings])
      session[:ratings].split(/,/).each do |rating|
        @ratings[rating] = 1 
      end
      params[:ratings] = @ratings
      redirect = true
    end
    redirect_to movies_path(params) if redirect
    @movies = Movie.find(:all,options);
    @title_class = "hilite" if params[:sort] == "title"
    @release_date_class = "hilite" if params[:sort] == "release_date"
    @title_uri = movies_path(params.update(:sort => 'title'))
    @release_date_uri = movies_path(params.update(:sort => 'release_date'))
    @all_ratings = Movie.ratings
    session[:ratings] = @ratings.keys.join(",")
    session[:sort] = @sort
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
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
