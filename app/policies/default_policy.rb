class DefaultPolicy
  attr_reader :request, :key, :record

  def initialize(context, record)
    @request = context.request
    @key = context.key
    @record = record
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    false
  end
  alias new? create?

  def update?
    false
  end
  alias edit? update?

  def destroy?
    false
  end
  alias delete? destroy?

  def admin?
    return true unless Sources::RBAC::Access.enabled?

    # TODO: remove org_admin after everyone has moved over.
    # Maybe even remove the `system` check
    request.system.present? || request.user&.org_admin? || psk_matches? || write_access?
  end

  def psk_matches?
    return false if self.class.pre_shared_key.nil?

    self.class.pre_shared_key == key
  end

  def self.pre_shared_key
    # memoizing as a class-var, defaulting to ""
    @pre_shared_key ||= ENV.fetch("SOURCES_PSK", nil)
  end

  delegate :write_access?, :to => Sources::RBAC::Access

  class Scope
    attr_reader :request, :key, :scope

    def initialize(context, scope)
      @request = context.request
      @key = context.key
      @scope = scope
    end

    def resolve
      scope.all
    end
  end
end
