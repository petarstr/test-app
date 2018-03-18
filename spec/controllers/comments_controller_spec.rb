require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:user_1) { User.find_by(email: 'test_user@gmail.com') }
  let(:project_1) { Project.find_by(project_name: 'Test Project', user_id: user_1.id) }
  let(:task_1) { Task.find_by(title: 'Test Task', project_id: project_1.id) }

  # Skip before hook when specified
  before do |example|
    sign_in_as(user_1) unless example.metadata[:skip_before]
  end

  after(:each) do
    CommentFile.destroy_all
  end

  describe 'GET #new' do
    context 'when not signed in' do
      it 'redirects to root', :skip_before do
        get :new, params: { task_id: task_1.id }
        expect(assigns(:task)).to be nil
        expect(assigns(:comments)).to be nil
        expect(assigns(:comment_files)).to be nil
        expect(response).to redirect_to sign_in_path
      end
    end
    context 'when user is not the owner of the task' do
      let(:task_2) { Task.find_by(title: 'New Test Task') }
      it 'redirects to root' do
        get :new, params: { task_id: task_2.id }
        expect(assigns(:task)).to be nil
        expect(assigns(:comments)).to be nil
        expect(assigns(:comment_files)).to be nil
        expect(response).to redirect_to root_url
      end
    end
    context 'when user owns the task' do
      it 'prepares new comment' do
        get :new, params: { task_id: task_1.id }
        expect(assigns(:task)).to eq task_1
        expect(assigns(:comment).new_record?).to be true
        expect(assigns(:comment_files).new_record?).to be true
      end
    end
  end

  describe 'POST #create' do
    context 'when user is not the owner of the task' do
      let(:task_2) { Task.find_by(title: 'New Test Task') }
      it 'does not allow to create new comment' do
        post :create, params: { task_id: task_2.id }
        expect(response).to redirect_to root_url
      end
    end
    context 'when comment is not present' do
      it 'does not create a record' do
        expect(Comment.all.length).to eq 2
        post :create, params: { task_id: task_1.id, comment: { comment: '' } }
        expect(Comment.all.length).to eq 2
      end
    end
    context 'when comment is present' do
      let!(:file_1) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/test_doc.txt") }
      let!(:file_2) { Rack::Test::UploadedFile.new("#{Rails.root}/spec/fixtures/test_doc_2.txt") }
      it 'creates a new task' do
        post :create, params: { task_id: task_1.id, comment: { comment: 'Another comment' }, comment_files: { file: [file_1, file_2] } }
        comment = Comment.find_by(comment: 'Another comment')
        expect(comment).to be_truthy
        expect(comment.task_id).to eq task_1.id
        expect(comment.comment_files.length).to eq 2
        expect(comment.comment_files.first.file_identifier).to eq 'test_doc.txt'
        expect(comment.comment_files.last.file_identifier).to eq 'test_doc_2.txt'
      end
    end
  end


  describe 'DELETE #destroy' do
    let!(:file) { File.open("#{Rails.root}/spec/fixtures/test_doc.txt") }
    let(:comment) { Comment.find_or_create_by(task_id: task_1.id, comment: 'Another comment') }
    let(:wrong_user) { User.find_by(email: 'another_test_user@gmail.com') }
    let(:comment_file_id) do
      cf = CommentFile.new(comment_id: comment.id, file: file )
      comment.comment_files << cf
      cf.id
    end

    context 'when the user is not the creator of the task' do
      it 'redirects to root', :skip_before do
        sign_in_as(wrong_user)
        delete :destroy, params: { id: comment.id }
        expect(response).to redirect_to root_url
        expect(comment.reload).to be_truthy
      end
    end

    context 'when the user owns the task' do
      it 'deletes the comment and associated files' do
        expect(CommentFile.find_by(id: comment_file_id)).to be_truthy
        delete :destroy, params: { id: comment.id }
        expect(Comment.find_by(id: comment.id)).to be nil
        expect(CommentFile.find_by(id: comment_file_id)).to be nil
      end
    end
  end
end
