class BooksController < ApplicationController
  before_action :ensure_correct_user, only:[:edit, :update]

  def show
    @book = Book.find(params[:id])
    @user = @book.user
    @book_new = Book.new
    @book_comments = @book.book_comments
    @book_comment = BookComment.new
  end

  def index
    to  = Time.current.at_end_of_day
    from  = (to - 6.day).at_beginning_of_day
    @books = Book.all.sort {|a,b| 
      b.favorites.where(created_at: from...to).size <=> 
      a.favorites.where(created_at: from...to).size
    }
    @book = Book.new
    @user = current_user
  end

  def create
    @book = Book.new(book_params)
    @book.user_id = current_user.id
    if @book.save
      flash[:notice] = "You have created book successfully."
      redirect_to book_path(@book)
    else
      @books = Book.all
      @user = current_user
      render :index
    end
  end

  def edit
    @book = Book.find(params[:id])
    if @book.user != current_user
       redirect_to :books
    end
  end

  def update
    @book = Book.find(params[:id])
    if @book.user != current_user
       redirect_to books_path
    end
      if @book.update(book_params)
        flash[:notice] = "You have updated book successfully."
        redirect_to book_path(@book)
      else
        render :edit
      end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path
  end
  
  def favorites
   @books = current_user.favorites_books
  end

  private

  def book_params
    params.require(:book).permit(:title, :body)
  end
  
  def ensure_correct_user
    @book =Book.find(params[:id])
     unless @book.user == current_user
     redirect_to books_path
     end
  end
end
