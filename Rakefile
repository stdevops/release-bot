$LOAD_PATH.unshift 'lib'

desc 'Runs the SQS job worker'
task :work do
  require 'conjur'
  require 'releasebot'
  require 'aws-sdk'
  
  Configuration.initialize!
  
  SQS::Job::Worker.new(Configuration.job_queue).run
end

desc 'Creates resources and loads access credentials into Conjur variables'
task :provision do
  [ 'POLICY_FILE', 'AWS_ACCESS_KEY_ID', 'AWS_SECRET_ACCESS_KEY' ].each do |v|
    ENV[v] or raise "#{v} is a required environment variable"
  end

  require 'json'

  policy = JSON.parse(File.read(ENV['POLICY_FILE']))
  ENV['CONJUR_POLICY_ID'] = policy_id = policy['policy']
  
  require 'conjur'
  require 'releasebot'
  require 'aws-sdk'
  
  Configuration.validate!
  conjur = Conjur::Authn.connect
  iam = AWS::IAM.new
  sqs = AWS::SQS.new

  job_provisioner = SQS::Job::Provisoner.new(conjur, policy_id)
  
  $stderr.puts "Creating signing key"
  job_provisioner.create_signing_key 'jobs'
  
  sqs_queue = begin
    sqs.queues.named(Configuration.job_queue_name)
  rescue AWS::SQS::Errors::NonExistentQueue
    $stderr.puts "Creating SQS queue #{Configuration.job_queue_name}"
    sqs.queues.create(Configuration.job_queue_name)
  end
  
  user = iam.users[Configuration.iam_user_name]
  unless user.exists?
    $stderr.puts "Creating IAM user #{Configuration.iam_user_name}"
    user = iam.users.create(Configuration.iam_user_name)
  end
  
  job_provisioner.permit_queue_send    user, sqs_queue
  job_provisioner.permit_queue_receive user, sqs_queue
    
  access_key = user.access_keys.create
  $stderr.puts "Saving access_key_id and secret_access_key"
  conjur.variable([ policy_id, 'aws/access_key_id'].join('/')).add_value     access_key.id
  conjur.variable([ policy_id, 'aws/secret_access_key'].join('/')).add_value access_key.secret
end
