# 데이터베이스 접근 기술 - Spring JdbcTemplate
### JdbcTemplate
SQL을 직접 사용하는 경우에 스프링에서 제공하는 JdbcTemplate을 사용하면
JDBC를 매우 편리하게 사용할 수 있다.

#### 장점
* 설정의 편리함
  * JdbcTemplate은 ```spring-jdbc```라이브러리에 포함 되어 있는데, 
  이 라이브러리는 스프링으로 JDBC를 사용할 때 기본으로 사용되는 라이브러리다.
  그리고 별도의 복잡한 설정 없이 바로 사용할 수 있다.
* 반복 문제 해결
  * JdbcTemplate은 템플릿 콜백 패턴을 사용해서,
  JDBC를 직접 사용할 때 발생하는 대부분의 반복작업을 대신 처리해준다.
  * 개발자는 SQL을 작성하고 전달할 파라미터를 정의하고, 응답값을 매핑하기만 하면된다.
  * 개발자가 생각할 수 있는 대부분의 반복 작업을 대신 처리해준다.
    * 커넥션 획득
    * ```statement```를 준비하고 실행
    * 결과를 반복하도록 루프를 실행
    * 커넥션 종료, ```statement```, ```resultSet```종료
    * 트랜잭션을 다루기 위한 커넥션 동기화
    * 예외 발생시 스프링 예외 변환기 실행
#### 단점
* 동적 SQL을 해결하기 어렵다.
***
# 데이터베이스 접근 기술 - Test
### 테스트 - 데이터베이스 연동
```@SpringBootTest```는 ```@SpringBootApplication```을 찾아 설정으로 사용한다.

### 테스트 - 데이터베이스 분리
애플리케이션 서버와 테스트에서 같은 데이터베이스를 사용하면 테스트에서 문제가 발생한다.
(데이터 중복, 삭제 등) 이 문제를 해결하려면 테스트를 다른 환경과 철저히 분리해야 한다.
가장 간단한 방법은 테스트 전용 데이터베이스를 별도로 운영하는 것이다.

데이터베이스를 별도로 분리해도 테스트를 반복하게 될 경우 데이터 중복, 삭데등의 문제가 다시 발생한다.
테스트에서 매우 중요한 원칙은 다음과 같다.
* 테스트는 다른 테스트와 격리해야 한다.(다른 테스트에 영향을 주어서는 안된다.)
* 테스트는 반복해서 실행할 수 있어야 한다.

### 테스트 - 데이터 롤백
테스트가 끝나고 트랜잭션을 강제로 롤백해버리면 데이터가 깔끔하게 제거된다.
트랜잭션을 커밋하지 않았기 때문에 데이터베이스에 해당 데이터가 반영되지 않는다.
테스트는 각각의 테스트 실행 전 후로 동작하는 ```@BeforeEach```, ```@AfterEach``` 라는 편리한 기능을
제공한다.

트랜잭션 매니저는 ```PlatformTransactionManager```를 주입받아서 사용하면 된다.
(스프링 부트는 자동으로 적절한 트랜잭션 매니저를 스프링 빈으로 등록해준다.)

* ```@BeforeEach```: 각각의 테스트 케이스를 실행하기 직전에 호출된다. 따라서 여기서 트랜잭션을 시작하면
된다. 그러면 각각의 테스트를 트랜잭션 범위 안에서 실행할 수 있다.
  * ```transactionManager.getTransaction(new DefaultTransactionDefinition())```로 트랜잭션을 시작한다.
* ```@AfterEach```:각각의 테스트 케이스가 완료된 직후에 호출된다. 따라서 여기서 트랜잭션을 롤백하면 된다.
    그러면 데이터를 트랜잭션 실행 전 상태로 복구할 수 있다.
  * ```transactionManager.rollback(status)``` 로 트랜잭션을 롤백한다.


### 테스트 - ```@Transactional```
스프링은 테스트 데이터 초기화를 위해 트랜잭션을 적용하고 롤백하는 방식을 ```@Transactional```애노테이션 하나로 깔끔하게 해결해준다.

### ```@Transactional``` 원리
스프링에서 제공하는 ```@Transactional```애노테이션은 로직이 성공적으로 수행되면 커밋하도록 동작한다.
그런데 ```@Transactional```이 테스트에 있으면 스프링은 테스트를 트랜잭션 안에서 실행하고, 테스트가 끝나면
트랜잭션을 자동으로 롤백시킨다.

### 강제로 커밋 ```@Commit```, ```@Rollback(value = false)```
```@Transactional```을 테스트에서 사용할 경우 테스트가 끝난 후 롤백되기 때문에 테스트 과정에서
저장한 데이터가 모두 사라진다. 데이터를 롤백이 아니라 저장까지한 후 직접 확인이 필요한 경우 ```@Commit```애노테이션을
클래스 또는 메서드에 붙이면 롤백대신 커밋이 된다. ```@Rollback(value = false)```도 같은 기능을 한다.

### 임베디드 모드 DB
단순히 테스트를 검증할 용도로만 데이터베이스를 사용하는 거라면 별도의 데이터베이스를 설치하고, 운영하는 것은 너무 번거로운 일이다.
H2데이터베이스는 자바로 개발되어 있고, JVM안에 메모리 모드로 동작하는 기능을 제공한다.
그래서 애플리케이션이 실행 될 때 H2데이터베이스도 JVM 메모리에 포함되 함께 실행 할 수 있다.
데이터베이스를 애플리케이션에 내장해서 함께 실행한다고 해서 임베디드 모드라 한다.

메모리 DB는 애플리케이션이 종료와 함께 사라지기 때문에 애플리케이션이 실행되는 시점에 데이터베이스의 테이블도 새로 만들어 주어야 한다.
JDBC나 JdbcTemplate를 직접 사용해 DDL을 실행시켜도 되지만, 스프링 부트는 SQL스크립트를 사용해 애플리케이션 로딩 시점에 데이터베이스 초기화 하는 기능을 제공한다.

```src/test/resources/schema.sql``` 파일을 생성하고 DDL을 작성하면 된다.

application.properties에 ```spring.datasource.url```, ```spring.datasource.username```을 설정하지 않으면
스프링 부트가 임베디드 데이터베이스를 실행시켜준다.
***
# 데이터베이스 접근 기술 - Mybatis
### Mybatis
기본적으로 JdbcTemplate이 제공하는 대부분의 기능을 제공한다.
SQL을 XML에 편리하게 작성할 수 있고 또 동적 쿼리를 매우 편리하게 작성할 수 있다는 점이다.

### 장점
* 여러줄의 SQL 작성시 편리함
  * JdbcTemplate - SQL 여러줄
    ```java
    String sql = "update item " +
     "set item_name=:itemName, price=:price, quantity=:quantity " +
     "where id=:id";
    ```
  * MyBatis - SQL 여러줄
    ```xml
    <update id="update">
      update item
      set item_name = #{itemName},
          price = #{price},
          quantity = #{quantity}
      where id = #{id}
    </update>
    ```
* 동적 SQL 작성시 편리함
  * JdbcTemplate - 동적 쿼리
  ```java
  String sql = "select id, item_name, price, quantity from item";
  //동적 쿼리
  if (StringUtils.hasText(itemName) || maxPrice != null) {
      sql += " where";
  }

  boolean andFlag = false;
  if (StringUtils.hasText(itemName)) {
      sql += " item_name like concat('%',:itemName,'%')";
      andFlag = true;
  }
  if (maxPrice != null) {
      if (andFlag) {
          sql += " and";
      }
      sql += " price <= :maxPrice";
  }
  log.info("sql={}", sql);
  return template.query(sql, param, itemRowMapper());
  ```
  * MyBatis - 동적 쿼리
  ```xml
  <select id="findAll" resultType="Item">
      select id, item_name, price, quantity
      from item
      <where>
          <if test="itemName != null and itemName != ''">
              and item_name like concat('%',#{itemName},'%')
          </if>
          <if test="maxPrice != null">
              and price &lt;= #{maxPrice}
          </if>
      </where>
  </select>
  ```
### 단점
  * JdbcTemplate은 스프링에 내장된 기능이고, 별도의 설정없이 사용할 수 있다는 장점이 있다. 반면에
    MyBatis는 약간의 설정이 필요하다.

### Mybatis 설정
```mybatis-spring-boot-starter```라이브러리를 사용하면 MyBatis를 스프링과 통합하고, 설정도 아주
간단히 할 수 있다.
```build.gradle```에 다음 의존 관계를 추가한다.
```angular2html
implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:2.2.0'
```
* 참고로 뒤에 버전 정보가 붙는 이유는 스프링 부트가 버전을 관리해주는 공식 라이브러리가 아니기
때문이다. 스프링 부트가 버전을 관리해주는 경우 버전 정보를 붙이지 않아도 최적의 버전을 자동으로
찾아준다.

의존 관계를 추가하면 다음과 같은 라이브러리가 추가된다.
* ```mybatis-spring-boot-starter```: MyBatis를 스프링 부트에서 편리하게 사용할 수 있게 시작하는
라이브러리
* ```mybatis-spring-boot-autoconfigure```: MyBatis와 스프링 부트 설정 라이브러리
* ```mybatis-spring```: MyBatis와 스프링을 연동하는 라이브러리
* ```mybatis```: MyBatis 라이브러리

라이브러리가 추가되면 ```application.properties```에 Mybatis 관련 설정들을 넣어준다.
* ```mybatis.type-aliases-package```:
  * Mybatis타입 정보를 사용할 때는 패키지 이름을 적어주어야 하는데, 여기에 명시하면 패키지
    이름을 생략할 수 있다.
  * 지정한 패키지와 그 하위 패키지가 자동으로 인식된다.
  * 여러 위치를 지정하려면 ```,```, ```;``` 로 구분하면 된다.
* ```mybatis.configuration.map-underscore-to-camel-case```:
  * JdbcTemplate의 BeanPropertyRowMapper 에서 처럼 언더바를 카멜로 자동 변경해주는 기능을
    활성화 한다.
* ```logging.level.hello.itemservice.repository.mybatis=trace```:
  * MyBatis에서 실행되는 쿼리 로그를 확인할 수 있다.
***
# 데이터베이스 접근 기술 - JPA
### JPA
JPA는 스프링과 더불어 자바 엔터프라이즈 시장의 주력 기술이다.
스프링이 DI 컨테이너를 포함한 애플리케이션 전반의 다양한 기능을 제공한다면, JPA는 ORM 데이터 접근 기술을 제공한다.

### ORM
Object Relational Mapping(객체-관계-매핑)의 약자로 객체와 데이터베이스를 매핑해주는 도구다.
ORM은 아래와 같은 문제를 해결하기 위해 등장하게 되었다.

* SQL 중심적인 개발의 문제점
  1. 객체를 관계형 DB에 저장 관리
  2. SQL 중심적인 개발 발생
  3. SQL 작성 무한 반복, 지루한 코드(객체를 SQL로, SQL을 객체로)
  4. SQL에 의존적인 개발을 피하기 어려워진다.
  5. 개발자가 SQL매퍼의 역할을 하게 된다.
* 객체와 관계형 데이터베이스 패러다임 불일치
  1. 객체를 객체 답게 모델링 할 수록 매핑 작업량이 늘어난다.

자바에서 ORM 기술을 쉽게 사용 할 수 있도록 해주는 기술이 JPA다.

### JPA 설정
```spring-boot-starter-data-jpa```라이브러리를 ```build.gradle```에 추가 한다.
```build.gradle```에 ```spring-boot-starter-jdbc```가 있다면 제거 한다.
```spring-boot-starter-data-jpa```에 포함(의존)되어 있다.

라이브러리 설정이 완료되면 다음과 같은 라이브러리가 추가 된다.
* ```hibernate-core```: JPA 구현체인 하이버네이트 라이브러리
* ```jakarta.persistence-api```: JPA 인터페이스
* ```spring-data-jpa```: 스프링 데이터 JPA 라이브러리

```application.properties```에 다음 설정을 추가한다.
```properties
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.type.descriptor.sql.BasicBinder=TRACE
```
* ```org.hibernate.SQL=DEBUG```:  하이버네이트가 생성하고 실행하는 SQL을 확인할 수 있다.
* ```org.hibernate.type.descriptor.sql.BasicBinder=TRACE```: SQL에 바인딩 되는 파라미터를 확인할
  수 있다.

#### 스프링 부트 3.0
스프링 부트 3.0 이상을 사용하면 하이버네이트 6버전을 사용하게 되는데
로그 설정 방식이 달라졌다. 다음과 같이 설정해야 한다.
```properties
logging.level.org.hibernate.SQL=DEBUG
logging.level.org.hibernate.orm.jdbc.bind=TRACE
```

### 장점
* 데이터 CRUD를 반복적인 SQL작성 없이 가능하게 해준다.

### 단점
* 동적 쿼리 작성이 번거롭고 복잡하다. (하지만 Querydsl 기술을 사용하면 매우 깔끔하게 사용할 수 있다.)
* SQL 작성시 SQL이 아닌 JPQL로 작성해야 한다. JPQL은 SQL과 매우 비슷하지만 다른부분이 존재한다.

#### JPQL
JPA는 JPQL(Java Persistence Query Language)라는 객체지향 쿼리 언어를 제공한다.
주로 여러 데이터를 복잡한 조건으로 조회할 때 사용한다. 작성시 대소문자를 구별하기 때문에 주의가 필요하다.
JPQL은 SQL과 문법이 거의 비슷하기 때문에 개발자들이 쉽게 적응할 수 있다.

