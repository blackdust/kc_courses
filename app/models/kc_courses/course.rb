module KcCourses
  class Course
    include Mongoid::Document
    include Mongoid::Timestamps
    include KcCourses::Concerns::Base
    include KcCourses::Concerns::CoursePublish
    include KcCourses::Concerns::CourseReadingMethods
    include KcCourses::Concerns::SubjectMethods
    include KcCourses::Concerns::CourseStatisticInfo
    include KcCourses::Concerns::CourseAuthorizeMethods

    scope :studing_of_user, ->(user) {
      if user == nil
        course_ids = []
      else
        course_ids = KcCourses::Course.all.select do |course|
          if course.read_percent_of_user(user) != 100 && course.ware_readings.count != 0
            course.id
          end
        end
      end
      where(:_id.in => course_ids)
    }

    scope :studied_of_user, ->(user) {
      if user == nil
        course_ids = []
      else
        course_ids = KcCourses::Course.all.select do |course|
          if course.read_percent_of_user(user) == 100
            course.id
          end
        end
      end
      where(:_id.in => course_ids)
    }



    field :name, :type => String
    field :desc, :type => String
    field :favorited_count, :type => Integer
    after_create :set_favorited_count_zero

    belongs_to :creator, class_name: 'User'
    belongs_to :cover_file_entity, class_name: 'FilePartUpload::FileEntity'

    has_many :chapters, class_name: 'KcCourses::Chapter'
    has_and_belongs_to_many :course_subjects, class_name: 'KcCourses::CourseSubject', inverse_of: nil

    validates :name, presence: true
    validates :creator, presence: true

    def cover(version=nil)
      (cover_file_entity and cover_file_entity.url(version)) || ENV['course_default_cover_url']
    end

    def set_favorited_count_zero
      self.favorited_count = 0
      self.save
    end
  end
end
