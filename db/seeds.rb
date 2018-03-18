low = Priority.find_or_create_by(status: 'Low')
medium = Priority.find_or_create_by(status: 'Medium')
high = Priority.find_or_create_by(status: 'High')

if Rails.env.test?
  user_1 = User.create!(
    email: 'test_user@gmail.com',
    password: 'test123'
  )

  user_2 = User.create!(
    email: 'another_test_user@gmail.com',
    password: 'test456'
  )

  project_1 = Project.find_or_create_by(project_name: 'Test Project', user_id: user_1.id)
  project_2 = Project.find_or_create_by(project_name: 'New Test Project', user_id: user_2.id)

  task_1 = Task.find_or_create_by(project_id: project_1.id, title: 'Test Task', description: 'Test description', priority_id: low.id)
  task_2 = Task.find_or_create_by(project_id: project_2.id, title: 'New Test Task', priority_id: low.id)

  comment_1 = Comment.find_or_create_by(task_id: task_1.id, comment: 'Test Comment')
  # file = File.open("#{Rails.root}/spec/fixtures/test_doc.txt")
  # comment_1.comment_files << CommentFile.new(comment_id: comment_1.id, file: file)

  comment_2 = Comment.find_or_create_by(task_id: task_2.id, comment: 'New Test Comment')
  # file_2 = File.open("#{Rails.root}/spec/fixtures/test_doc_2.txt")
  # comment_2.comment_files << CommentFile.new(comment_id: comment_2.id, file: file_2)
end
