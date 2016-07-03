User.create! name: "Admin", email: "admin@e-learning.com",
  password: "saocungduochihi", password_confirmation: "saocungduochihi",
  is_admin: true

30.times do |i|
  password = "password"
  User.create! name: "User #{i+1}", email: "account-#{i+1}@e-learning.com",
    password: "password", password_confirmation: "password"
end

user  = User.first
following = User.all[2..30]
followers = User.all[3..20]
following.each do |followed|
  user.follow followed
  user.store_action Activity.actions[:follow], followed.id
end
followers.each do |follower|
  follower.follow user
  follower.store_action Activity.actions[:follow], user.id
end

11.times do |i|
  category = Category.create! name: "Category #{i}"
  i.times do |j|
    word = category.words.build name: "word #{i}-#{j + 1}"
    total_answer = 2 + rand(5)
    correct = rand total_answer
    start = j + 1 - correct
    total_answer.times do |k|
      word.word_answers.build content: "answer #{start  + k}",
        is_correct: (start + k) == (j + 1)
    end
    word.save!
  end
end
