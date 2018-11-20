class AnswersController < ApplicationController
  include Voted

  before_action :authenticate_user!, only: [ :update, :new, :create ]
  before_action :find_question, only: %i[ create ]
  before_action :find_answer, only: %i[ update destroy find_best_answer ]
  after_action :publish_answer, only: :create

  def create
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user

    if @answer.save
      redirect_to @question, notice: 'Your answer successfully created.'
    else
      render 'questions/show', notice: 'Your answer was not created.'
    end
  end

  def update
    @answer.update(answer_params) if current_user.author_of?(@answer)
  end

  def destroy
    @answer.destroy if current_user.author_of?(@answer)
    redirect_to question_path(@answer.question)
  end

  def find_best_answer
    @question = @answer.question
    @answer.find_best_answer if current_user.author_of?(@question)
  end

  private

  def find_question
    @question = Question.find(params[:question_id])
  end

  def find_answer
    @answer = Answer.find(params[:id])
  end

  def answer_params
    params.require(:answer).permit(:body, attachments_attributes: [:file, :destroy])
  end

  def publish_answer
    return if @answer.errors.any?
    ActionCable.server.broadcast(
      "answers_question_#{@question.id}",
      answer: @answer,
      attachments: @answer.attachments,
      rating: @answer.rating
    )
  end
end
