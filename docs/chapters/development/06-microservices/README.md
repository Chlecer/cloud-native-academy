# 🏗️ Microservices: How Netflix Serves 15 Billion Hours Monthly

> **The inside story of Netflix's transformation from a monolith that crashed every weekend to 700+ microservices serving 200M users globally**

## 💥 The Monolith That Nearly Killed Netflix

**2008 - Netflix's Monolithic Nightmare:**
- **Single massive application** handling everything
- **Weekend crashes** became routine
- **3-day deployments** with 50% failure rate
- **One bug** could bring down the entire platform
- **Scaling nightmare**: Adding servers didn't help

**The breaking point**: August 2008 - A database corruption took Netflix offline for 3 days, losing millions in revenue and nearly bankrupting the company.

**2024 - Netflix's Microservices Mastery:**
- **700+ independent services** running simultaneously
- **15+ billion hours** of content streamed monthly
- **4,000+ deployments daily** with 99.9% success rate
- **Global scale**: 190+ countries, zero downtime
- **Auto-scaling**: Handles 10x traffic spikes automatically

**The transformation**: Netflix's microservices architecture now processes 1 billion+ requests per day.

---

## 🚀 The Amazon Microservices Revolution

### How Amazon Went from Monolith to 100,000+ Services

**Jeff Bezos's Famous Mandate (2002):**
> "All teams will henceforth expose their data and functionality through service interfaces. Teams must communicate with each other through these interfaces. No other form of interprocess communication is allowed. Anyone who doesn't do this will be fired."

**Amazon's Microservices Scale (2024):**
- **100,000+ microservices** running in production
- **50 million deployments** per year
- **11 seconds average** deployment time
- **99.99% availability** across all services

```javascript
// Amazon's Service-Oriented Architecture Pattern
class AmazonMicroservice {
  constructor(serviceName) {
    this.serviceName = serviceName;
    this.dependencies = new Map();
    this.circuitBreakers = new Map();
    this.metrics = new MetricsCollector();
  }

  // 1. Service Discovery Pattern
  async discoverService(serviceName) {
    const serviceRegistry = new AWSServiceDiscovery();
    
    try {
      const serviceInstances = await serviceRegistry.discoverInstances({
        NamespaceName: 'amazon-production',
        ServiceName: serviceName
      });

      // Health check all instances
      const healthyInstances = await Promise.all(
        serviceInstances.map(async (instance) => {
          const isHealthy = await this.healthCheck(instance.endpoint);
          return isHealthy ? instance : null;
        })
      );

      return healthyInstances.filter(Boolean);
    } catch (error) {
      console.error(`Service discovery failed for ${serviceName}:`, error);
      return [];
    }
  }

  // 2. Circuit Breaker Pattern (Prevents cascade failures)
  async callService(serviceName, request) {
    const circuitBreaker = this.getCircuitBreaker(serviceName);
    
    if (circuitBreaker.isOpen()) {
      console.log(`Circuit breaker OPEN for ${serviceName} - using fallback`);
      return this.getFallbackResponse(serviceName, request);
    }

    try {
      const startTime = Date.now();
      const response = await this.makeServiceCall(serviceName, request);
      const duration = Date.now() - startTime;

      // Record success
      circuitBreaker.recordSuccess();
      this.metrics.recordLatency(serviceName, duration);
      
      return response;
    } catch (error) {
      // Record failure
      circuitBreaker.recordFailure();
      this.metrics.recordError(serviceName, error);

      if (circuitBreaker.shouldOpen()) {
        console.log(`Opening circuit breaker for ${serviceName}`);
        circuitBreaker.open();
      }

      return this.getFallbackResponse(serviceName, request);
    }
  }

  // 3. Bulkhead Pattern (Isolate resources)
  async processOrder(orderData) {
    // Separate thread pools for different operations
    const inventoryPool = this.getThreadPool('inventory', { size: 10 });
    const paymentPool = this.getThreadPool('payment', { size: 5 });
    const shippingPool = this.getThreadPool('shipping', { size: 8 });

    try {
      // Parallel processing with isolation
      const [inventory, payment, shipping] = await Promise.all([
        inventoryPool.execute(() => this.checkInventory(orderData)),
        paymentPool.execute(() => this.processPayment(orderData)),
        shippingPool.execute(() => this.calculateShipping(orderData))
      ]);

      return this.createOrder({ inventory, payment, shipping });
    } catch (error) {
      // If one service fails, others continue working
      console.error('Order processing failed:', error);
      throw error;
    }
  }

  // 4. Saga Pattern (Distributed transactions)
  async executeOrderSaga(orderData) {
    const saga = new Saga('process-order');
    
    try {
      // Step 1: Reserve inventory
      const inventoryReservation = await saga.execute(
        'reserve-inventory',
        () => this.inventoryService.reserve(orderData.items),
        () => this.inventoryService.release(orderData.items) // Compensation
      );

      // Step 2: Process payment
      const paymentResult = await saga.execute(
        'process-payment',
        () => this.paymentService.charge(orderData.payment),
        () => this.paymentService.refund(paymentResult.transactionId) // Compensation
      );

      // Step 3: Create shipment
      const shipment = await saga.execute(
        'create-shipment',
        () => this.shippingService.createShipment(orderData),
        () => this.shippingService.cancelShipment(shipment.id) // Compensation
      );

      // Step 4: Send confirmation
      await saga.execute(
        'send-confirmation',
        () => this.notificationService.sendOrderConfirmation(orderData),
        () => this.notificationService.sendCancellation(orderData) // Compensation
      );

      await saga.complete();
      return { success: true, orderId: orderData.id };

    } catch (error) {
      // Automatic compensation for all completed steps
      await saga.compensate();
      throw new Error(`Order processing failed: ${error.message}`);
    }
  }
}

// Amazon's Circuit Breaker Implementation
class CircuitBreaker {
  constructor(serviceName, options = {}) {
    this.serviceName = serviceName;
    this.failureThreshold = options.failureThreshold || 5;
    this.recoveryTimeout = options.recoveryTimeout || 60000; // 1 minute
    this.monitoringPeriod = options.monitoringPeriod || 10000; // 10 seconds
    
    this.state = 'CLOSED'; // CLOSED, OPEN, HALF_OPEN
    this.failures = 0;
    this.lastFailureTime = null;
    this.successCount = 0;
  }

  isOpen() {
    return this.state === 'OPEN';
  }

  shouldOpen() {
    return this.failures >= this.failureThreshold;
  }

  recordSuccess() {
    this.failures = 0;
    this.successCount++;
    
    if (this.state === 'HALF_OPEN') {
      if (this.successCount >= 3) {
        this.state = 'CLOSED';
        console.log(`Circuit breaker CLOSED for ${this.serviceName}`);
      }
    }
  }

  recordFailure() {
    this.failures++;
    this.lastFailureTime = Date.now();
    
    if (this.state === 'HALF_OPEN') {
      this.state = 'OPEN';
    }
  }

  open() {
    this.state = 'OPEN';
    this.lastFailureTime = Date.now();
    
    // Auto-recovery timer
    setTimeout(() => {
      if (this.state === 'OPEN') {
        this.state = 'HALF_OPEN';
        this.successCount = 0;
        console.log(`Circuit breaker HALF_OPEN for ${this.serviceName}`);
      }
    }, this.recoveryTimeout);
  }
}
```

**Amazon's Microservices Results:**
- **99.99% availability** across all services
- **50 million deployments** annually with minimal failures
- **$500B+ revenue** enabled by microservices architecture
- **11-second deployments** vs. hours with monoliths

---

## 🎬 Netflix's Microservices Architecture

### The 700-Service Symphony That Never Stops

```python
# Netflix's Microservices Ecosystem
class NetflixMicroservicesArchitecture:
    def __init__(self):
        self.services = {
            # User Management
            'user-service': UserService(),
            'profile-service': ProfileService(),
            'preferences-service': PreferencesService(),
            
            # Content Management
            'content-catalog': ContentCatalogService(),
            'metadata-service': MetadataService(),
            'encoding-service': EncodingService(),
            
            # Recommendation Engine
            'recommendation-service': RecommendationService(),
            'personalization-service': PersonalizationService(),
            'trending-service': TrendingService(),
            
            # Streaming Infrastructure
            'video-streaming': VideoStreamingService(),
            'cdn-service': CDNService(),
            'quality-service': QualityService(),
            
            # Business Logic
            'billing-service': BillingService(),
            'subscription-service': SubscriptionService(),
            'analytics-service': AnalyticsService()
        }
        
        self.service_mesh = IstioServiceMesh()
        self.monitoring = NetflixMonitoring()
    
    async def get_user_homepage(self, user_id):
        """
        Netflix's homepage generation involves 50+ microservices
        """
        try:
            # 1. Get user context (parallel calls)
            user_data, preferences, viewing_history = await asyncio.gather(
                self.services['user-service'].get_user(user_id),
                self.services['preferences-service'].get_preferences(user_id),
                self.services['viewing-history'].get_history(user_id)
            )
            
            # 2. Generate personalized recommendations
            recommendations = await self.services['recommendation-service'].generate(
                user_id=user_id,
                preferences=preferences,
                history=viewing_history,
                context={'time_of_day': datetime.now().hour, 'device': 'tv'}
            )
            
            # 3. Get trending content for user's region
            trending = await self.services['trending-service'].get_trending(
                region=user_data.region,
                age_group=user_data.age_group
            )
            
            # 4. Fetch content metadata (batch operation)
            content_ids = recommendations.content_ids + trending.content_ids
            content_metadata = await self.services['metadata-service'].get_batch(content_ids)
            
            # 5. Check content availability and quality
            availability = await self.services['content-catalog'].check_availability(
                content_ids=content_ids,
                user_subscription=user_data.subscription_tier,
                region=user_data.region
            )
            
            # 6. Generate personalized homepage layout
            homepage = await self.services['personalization-service'].create_homepage({
                'user': user_data,
                'recommendations': recommendations,
                'trending': trending,
                'metadata': content_metadata,
                'availability': availability
            })
            
            # 7. Log for analytics and ML training
            await self.services['analytics-service'].log_homepage_generation({
                'user_id': user_id,
                'content_shown': homepage.content_ids,
                'generation_time': time.time(),
                'ab_test_variant': homepage.ab_test_variant
            })
            
            return homepage
            
        except Exception as error:
            # Graceful degradation - show cached or default content
            return await self.get_fallback_homepage(user_id, error)
    
    async def handle_video_playback(self, user_id, content_id):
        """
        Video playback involves 20+ microservices working together
        """
        try:
            # 1. Validate user subscription and content access
            access_check = await asyncio.gather(
                self.services['subscription-service'].validate_access(user_id),
                self.services['content-catalog'].check_license(content_id, user_id)
            )
            
            if not all(access_check):
                raise UnauthorizedError("User cannot access this content")
            
            # 2. Get optimal video quality based on network/device
            user_context = await self.services['user-service'].get_context(user_id)
            optimal_quality = await self.services['quality-service'].determine_quality(
                user_context.network_speed,
                user_context.device_capabilities,
                user_context.data_plan
            )
            
            # 3. Find best CDN endpoint for user's location
            cdn_endpoint = await self.services['cdn-service'].get_optimal_endpoint(
                content_id=content_id,
                user_location=user_context.location,
                quality=optimal_quality
            )
            
            # 4. Generate secure streaming URL with time-limited token
            streaming_url = await self.services['video-streaming'].generate_url(
                content_id=content_id,
                quality=optimal_quality,
                cdn_endpoint=cdn_endpoint,
                user_id=user_id,
                expires_in=3600  # 1 hour
            )
            
            # 5. Start analytics tracking
            await self.services['analytics-service'].start_playback_session({
                'user_id': user_id,
                'content_id': content_id,
                'quality': optimal_quality,
                'cdn_endpoint': cdn_endpoint,
                'start_time': time.time()
            })
            
            # 6. Pre-load next episode/recommendations
            asyncio.create_task(self.preload_next_content(user_id, content_id))
            
            return {
                'streaming_url': streaming_url,
                'quality': optimal_quality,
                'subtitles': await self.get_subtitles(content_id, user_context.language),
                'next_episode': await self.get_next_episode(content_id)
            }
            
        except Exception as error:
            await self.services['analytics-service'].log_playback_error(user_id, content_id, error)
            raise
    
    async def handle_service_failure(self, failed_service, error):
        """
        Netflix's chaos engineering and failure handling
        """
        print(f"🚨 Service failure detected: {failed_service}")
        
        # 1. Immediate circuit breaker activation
        await self.service_mesh.open_circuit_breaker(failed_service)
        
        # 2. Route traffic to healthy instances
        healthy_instances = await self.service_mesh.get_healthy_instances(failed_service)
        if healthy_instances:
            await self.service_mesh.route_traffic(failed_service, healthy_instances)
        
        # 3. Activate fallback mechanisms
        fallback_responses = {
            'recommendation-service': self.get_cached_recommendations,
            'content-catalog': self.get_cached_catalog,
            'user-service': self.get_cached_user_data
        }
        
        if failed_service in fallback_responses:
            await self.activate_fallback(failed_service, fallback_responses[failed_service])
        
        # 4. Auto-scaling response
        if self.is_load_related_failure(error):
            await self.auto_scale_service(failed_service, scale_factor=2.0)
        
        # 5. Alert engineering teams
        await self.monitoring.alert_oncall_team({
            'service': failed_service,
            'error': str(error),
            'impact': await self.assess_user_impact(failed_service),
            'mitigation_actions': ['circuit_breaker', 'fallback_activated', 'auto_scaling']
        })
        
        # 6. Chaos Monkey learning
        await self.chaos_monkey.learn_from_failure(failed_service, error)

# Netflix's Service Mesh Configuration
class NetflixServiceMesh:
    def __init__(self):
        self.istio = IstioConfig()
        self.envoy_proxies = {}
        self.traffic_policies = {}
    
    async def configure_traffic_management(self):
        """
        Netflix's advanced traffic management
        """
        # Canary deployments
        canary_config = {
            'recommendation-service': {
                'stable_version': 'v1.2.3',
                'canary_version': 'v1.2.4',
                'traffic_split': {'stable': 90, 'canary': 10},
                'success_criteria': {
                    'error_rate': '<0.1%',
                    'latency_p99': '<200ms',
                    'user_satisfaction': '>95%'
                }
            }
        }
        
        # Circuit breaker configuration
        circuit_breaker_config = {
            'consecutive_errors': 5,
            'interval': '30s',
            'base_ejection_time': '30s',
            'max_ejection_percent': 50
        }
        
        # Retry policies
        retry_config = {
            'attempts': 3,
            'per_try_timeout': '2s',
            'retry_on': ['5xx', 'reset', 'connect-failure', 'refused-stream']
        }
        
        await self.istio.apply_config({
            'canary': canary_config,
            'circuit_breaker': circuit_breaker_config,
            'retry': retry_config
        })
```

**Netflix's Microservices Results:**
- **15+ billion hours** streamed monthly
- **700+ services** running simultaneously
- **99.97% uptime** during peak traffic
- **4,000+ deployments daily** with zero user impact

---

## 🛒 Shopify's Commerce Microservices

### How Shopify Handles $200B+ in Commerce

```ruby
# Shopify's Microservices for E-commerce Scale
class ShopifyMicroservicesArchitecture
  def initialize
    @services = {
      # Core Commerce
      product_catalog: ProductCatalogService.new,
      inventory_management: InventoryService.new,
      pricing_engine: PricingService.new,
      
      # Order Management
      cart_service: CartService.new,
      checkout_service: CheckoutService.new,
      order_service: OrderService.new,
      
      # Payment Processing
      payment_gateway: PaymentGatewayService.new,
      fraud_detection: FraudDetectionService.new,
      tax_calculation: TaxService.new,
      
      # Fulfillment
      shipping_service: ShippingService.new,
      warehouse_management: WarehouseService.new,
      tracking_service: TrackingService.new
    }
    
    @event_bus = ShopifyEventBus.new
    @monitoring = ShopifyMonitoring.new
  end
  
  # Black Friday: Handle 80,000+ requests/second
  def process_checkout(checkout_data)
    checkout_id = SecureRandom.uuid
    
    begin
      # 1. Validate cart and inventory (parallel)
      cart_validation, inventory_check = Concurrent::Future.zip(
        Concurrent::Future.execute { @services[:cart_service].validate(checkout_data[:cart]) },
        Concurrent::Future.execute { @services[:inventory_management].check_availability(checkout_data[:items]) }
      ).value!
      
      raise CheckoutError, "Cart validation failed" unless cart_validation.valid?
      raise CheckoutError, "Items out of stock" unless inventory_check.available?
      
      # 2. Calculate pricing with taxes and discounts
      pricing = @services[:pricing_engine].calculate_total(
        items: checkout_data[:items],
        customer: checkout_data[:customer],
        shipping_address: checkout_data[:shipping_address],
        discount_codes: checkout_data[:discount_codes]
      )
      
      # 3. Fraud detection (real-time ML)
      fraud_score = @services[:fraud_detection].analyze_transaction(
        customer: checkout_data[:customer],
        payment_method: checkout_data[:payment],
        order_value: pricing.total,
        shipping_address: checkout_data[:shipping_address],
        device_fingerprint: checkout_data[:device_info]
      )
      
      if fraud_score.risk_level == 'HIGH'
        return { success: false, error: 'Transaction flagged for review' }
      end
      
      # 4. Reserve inventory
      reservation = @services[:inventory_management].reserve_items(
        checkout_data[:items],
        expires_at: 15.minutes.from_now
      )
      
      # 5. Process payment
      payment_result = @services[:payment_gateway].process_payment(
        amount: pricing.total,
        payment_method: checkout_data[:payment],
        customer: checkout_data[:customer],
        fraud_score: fraud_score
      )
      
      unless payment_result.success?
        @services[:inventory_management].release_reservation(reservation.id)
        return { success: false, error: payment_result.error }
      end
      
      # 6. Create order
      order = @services[:order_service].create_order(
        checkout_data: checkout_data,
        pricing: pricing,
        payment: payment_result,
        reservation: reservation
      )
      
      # 7. Initiate fulfillment
      fulfillment = @services[:shipping_service].create_fulfillment(
        order: order,
        shipping_method: checkout_data[:shipping_method]
      )
      
      # 8. Publish events for other services
      @event_bus.publish('order.created', {
        order_id: order.id,
        customer_id: checkout_data[:customer][:id],
        total: pricing.total,
        items: checkout_data[:items]
      })
      
      # 9. Send confirmation
      NotificationService.send_order_confirmation(order)
      
      {
        success: true,
        order_id: order.id,
        confirmation_number: order.confirmation_number,
        estimated_delivery: fulfillment.estimated_delivery
      }
      
    rescue => error
      # Compensating transactions
      @services[:inventory_management].release_reservation(reservation&.id)
      @services[:payment_gateway].refund_payment(payment_result&.transaction_id)
      
      @monitoring.log_checkout_error(checkout_id, error)
      { success: false, error: 'Checkout failed. Please try again.' }
    end
  end
  
  # Event-driven architecture for real-time updates
  def setup_event_handlers
    @event_bus.subscribe('inventory.updated') do |event|
      # Update product availability across all channels
      @services[:product_catalog].update_availability(
        product_id: event[:product_id],
        quantity: event[:new_quantity]
      )
      
      # Notify customers with items in cart
      customers_with_item = @services[:cart_service].find_customers_with_item(event[:product_id])
      customers_with_item.each do |customer|
        NotificationService.send_inventory_update(customer, event)
      end
    end
    
    @event_bus.subscribe('payment.failed') do |event|
      # Automatic retry with different payment method
      if event[:retry_count] < 3
        alternative_payment = @services[:payment_gateway].get_alternative_method(event[:customer_id])
        if alternative_payment
          @services[:payment_gateway].retry_payment(event[:order_id], alternative_payment)
        end
      end
    end
    
    @event_bus.subscribe('order.shipped') do |event|
      # Update inventory, send tracking info, trigger reviews
      @services[:inventory_management].confirm_shipment(event[:order_id])
      @services[:tracking_service].start_tracking(event[:tracking_number])
      
      # Schedule review request for 3 days after delivery
      ReviewService.schedule_review_request(
        order_id: event[:order_id],
        send_at: event[:estimated_delivery] + 3.days
      )
    end
  end
end

# Shopify's Event Bus for Microservices Communication
class ShopifyEventBus
  def initialize
    @subscribers = Hash.new { |h, k| h[k] = [] }
    @redis = Redis.new
    @kafka = Kafka.new(['kafka1:9092', 'kafka2:9092'])
  end
  
  def publish(event_type, data)
    event = {
      id: SecureRandom.uuid,
      type: event_type,
      data: data,
      timestamp: Time.current.iso8601,
      source: 'shopify-core'
    }
    
    # Publish to Kafka for durability
    @kafka.deliver_message(
      event.to_json,
      topic: "shopify-events",
      key: event_type
    )
    
    # Publish to Redis for real-time processing
    @redis.publish("events:#{event_type}", event.to_json)
    
    # Execute local subscribers immediately
    @subscribers[event_type].each do |subscriber|
      begin
        subscriber.call(data)
      rescue => error
        Rails.logger.error "Event subscriber error: #{error}"
      end
    end
  end
  
  def subscribe(event_type, &block)
    @subscribers[event_type] << block
    
    # Also subscribe to Redis for cross-service events
    Thread.new do
      @redis.subscribe("events:#{event_type}") do |on|
        on.message do |channel, message|
          event_data = JSON.parse(message)
          block.call(event_data['data'])
        end
      end
    end
  end
end
```

**Shopify's Microservices Results:**
- **$200+ billion** in commerce processed annually
- **80,000+ requests/second** during Black Friday
- **99.99% uptime** during peak shopping events
- **Millions of merchants** served simultaneously

---

## 💰 The Business Impact of Microservices

### ROI of Microservices Architecture

**Scalability Benefits:**
- **Netflix**: 15B+ hours streamed with 700+ services
- **Amazon**: 100,000+ services handling global e-commerce
- **Shopify**: $200B+ commerce with independent scaling
- **Uber**: 2,000+ services for global ride-sharing

**Development Velocity:**
- **Deployment frequency**: 100x faster than monoliths
- **Team independence**: Multiple teams ship simultaneously
- **Technology diversity**: Best tool for each job
- **Fault isolation**: One service failure doesn't kill everything

**Career Impact:**
- **Microservices Architect**: $160,000 - $250,000
- **Platform Engineer**: $140,000 - $220,000
- **Site Reliability Engineer**: $130,000 - $200,000
- **Microservices expertise**: 40-50% salary premium

---

## 🎓 What You've Mastered

- ✅ **Netflix's 700-service architecture** (15B+ hours monthly)
- ✅ **Amazon's 100,000+ services** (global e-commerce scale)
- ✅ **Shopify's commerce microservices** ($200B+ processed)
- ✅ **Circuit breaker patterns** (prevent cascade failures)
- ✅ **Service mesh management** (traffic control & monitoring)
- ✅ **Event-driven architecture** (real-time system coordination)

**Sources**: Netflix Tech Blog, Amazon Architecture Center, Shopify Engineering, Microservices Patterns (Chris Richardson)

---

**Next:** [Security - Auth Systems](../../security/01-auth-systems/) - Learn how Auth0 secures 100M+ users with zero-trust architecture