require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  let(:user_1) { User.find_by(email: 'test_user@gmail.com') }
  let(:project_1) { Project.find_by(project_name: 'Test Project', user_id: user_1.id) }

  # Skip before hook when specified
  before do |example|
    sign_in_as(user_1) unless example.metadata[:skip_before]
  end

  describe 'GET #index' do
    context 'when not signed in' do
      it 'redirects to root', :skip_before do
        get :index, params: { project_id: project_1.id }
        expect(assigns(:project)).to be nil
        expect(assigns(:tasks)).to be nil
        expect(response).to redirect_to sign_in_path
      end
    end

    context 'when signed in user' do
      it 'collects project tasks' do
        get :index, params: { project_id: project_1.id }
        expect(assigns(:project)).to eq project_1
        expect(assigns(:tasks)).to eq project_1.tasks
      end
    end
  end

  describe 'GET #show' do
    it 'shows a specific task' do
      get :show, params: { id: project_1.tasks.first.id }
      expect(assigns(:task)).to eq project_1.tasks.first
    end
  end

  describe 'GET #new' do
    context 'when user is not the owner of the project' do
      let(:project_2) { Project.find_by(project_name: 'New Test Project') }
      it 'does not allow to create new task' do
        get :new, params: { project_id: project_2.id }
        expect(assigns(:tasks)).to be nil
        expect(assigns(:project)).to be nil
        expect(response).to redirect_to root_url
      end
    end
    context 'when user is the owner of the project' do
      it 'prepares new task' do
        get :new, params: { project_id: project_1.id }
        expect(assigns(:project)).to eq project_1
        expect(assigns(:task).new_record?).to be true
      end
    end
  end

  describe 'POST #create' do
    context 'when user is not the owner of the project' do
      let(:project_2) { Project.find_by(project_name: 'New Test Project') }
      it 'does not allow to create new task' do
        post :create, params: { project_id: project_2.id }
        expect(response).to redirect_to root_url
      end
    end
    context 'when task title is not present' do
      it 'does not create a record' do
        post :create, params: { project_id: project_1.id, task: { title: '' } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when task title is present' do
      it 'creates a new task' do
        post :create, params: { project_id: project_1.id, task: { title: 'Such a great task', priority_id: 1 } }
        task = Task.find_by(title: 'Such a great task')
        expect(task).to be_truthy
        expect(task.project_id).to eq project_1.id
        expect(task.title).to eq 'Such a great task'
        expect(task.priority_id).to eq 1
      end
    end
  end

  describe 'PUT #update' do
    let(:task) { Task.find_or_create_by(project_id: project_1.id, title: 'Such an amazing functionality', priority_id: 3) }
    let(:wrong_user) { User.find_by(email: 'another_test_user@gmail.com') }

    context 'when the user is not the creator of the project' do
      it 'redirects to root', :skip_before do
        sign_in_as(wrong_user)
        put :update, params: { id: task.id, task: { title: 'valid task name'} }
        expect(response).to redirect_to root_url
      end
    end

    context 'when the user owns the project' do
      it 'updates task' do
        put :update, params: { id: task.id, task: { title: 'valid task name', description: 'desc', priority_id: 1} }
        expect(task.reload.title).to eq 'valid task name'
        expect(task.reload.description).to eq 'desc'
        expect(task.reload.priority_id).to eq 1
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:task) { Task.find_or_create_by(project_id: project_1.id, title: 'Such an amazing functionality', priority_id: 3) }
    let(:wrong_user) { User.find_by(email: 'another_test_user@gmail.com') }

    context 'when the user is not the creator of the task' do
      it 'redirects to root', :skip_before do
        sign_in_as(wrong_user)
        delete :destroy, params: { id: task.id }
        expect(response).to redirect_to root_url
        expect(task.reload).to be_truthy
      end
    end

    context 'when the user owns the task' do
      it 'deletes the task' do
        delete :destroy, params: { id: task.id }
        expect(Task.find_by(id: task.id)).to be nil
      end
    end
  end
end
