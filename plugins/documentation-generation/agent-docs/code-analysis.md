# Code Analysis

> AST 파싱, 의존성 분석, 자동 문서 추출 방법

## Overview

코드 구조를 분석하여 자동으로 문서를 생성하는 프로세스를 설명합니다.

```
CODE ANALYSIS PIPELINE:
┌─────────────────────────────────────────────────────────┐
│                   Source Code                            │
│           (TypeScript, Python, Go, Java...)              │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                  AST Parsing                             │
│    ├─ Language Detection                                │
│    ├─ Syntax Tree Generation                            │
│    └─ Node Extraction                                   │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│              Semantic Analysis                           │
│    ├─ Type Resolution                                   │
│    ├─ Symbol References                                 │
│    └─ Relationship Mapping                              │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│            Documentation Generation                      │
│    ├─ API Documentation                                 │
│    ├─ Type Definitions                                  │
│    └─ Usage Examples                                    │
└─────────────────────────────────────────────────────────┘
```

---

## 언어별 AST 파싱

### TypeScript/JavaScript

```
TYPESCRIPT AST NODES:
├─ Program
│   ├─ ImportDeclaration
│   │   ├─ source: string
│   │   └─ specifiers: ImportSpecifier[]
│   │
│   ├─ ClassDeclaration
│   │   ├─ name: Identifier
│   │   ├─ decorators: Decorator[]
│   │   ├─ members: ClassMember[]
│   │   └─ heritage: HeritageClause[]
│   │
│   ├─ InterfaceDeclaration
│   │   ├─ name: Identifier
│   │   ├─ members: TypeElement[]
│   │   └─ extends: HeritageClause[]
│   │
│   ├─ FunctionDeclaration
│   │   ├─ name: Identifier
│   │   ├─ parameters: Parameter[]
│   │   ├─ returnType: TypeNode
│   │   └─ body: Block
│   │
│   └─ ExportDeclaration
│       ├─ namedExports: ExportSpecifier[]
│       └─ moduleSpecifier: string
```

#### 추출 예시

```typescript
// 입력 코드
@Controller('users')
export class UserController {
  @Get()
  async getUsers(@Query() query: UserQueryDto): Promise<User[]> {
    return this.userService.findAll(query);
  }
}

// AST 분석 결과
{
  "type": "ClassDeclaration",
  "decorators": [
    { "name": "Controller", "args": ["users"] }
  ],
  "name": "UserController",
  "methods": [
    {
      "name": "getUsers",
      "decorators": [{ "name": "Get" }],
      "parameters": [
        {
          "name": "query",
          "type": "UserQueryDto",
          "decorator": "Query"
        }
      ],
      "returnType": "Promise<User[]>",
      "async": true
    }
  ]
}

// 생성된 문서
### GET /users

**Controller**: `UserController`

**Method**: `getUsers`

**Query Parameters**:
- `query`: `UserQueryDto`

**Response**: `Promise<User[]>`
```

### Python

```
PYTHON AST NODES:
├─ Module
│   ├─ Import
│   │   └─ names: alias[]
│   │
│   ├─ ClassDef
│   │   ├─ name: str
│   │   ├─ bases: expr[]
│   │   ├─ decorator_list: expr[]
│   │   └─ body: stmt[]
│   │
│   ├─ FunctionDef
│   │   ├─ name: str
│   │   ├─ args: arguments
│   │   ├─ returns: expr
│   │   ├─ decorator_list: expr[]
│   │   └─ body: stmt[]
│   │
│   └─ Assign
│       ├─ targets: expr[]
│       └─ value: expr
```

#### 추출 예시

```python
# 입력 코드
@dataclass
class User:
    """User entity"""
    id: int
    name: str
    email: str

    def to_dict(self) -> dict:
        """Convert to dictionary"""
        return asdict(self)

# AST 분석 결과
{
  "type": "ClassDef",
  "name": "User",
  "docstring": "User entity",
  "decorators": ["dataclass"],
  "attributes": [
    {"name": "id", "type": "int"},
    {"name": "name", "type": "str"},
    {"name": "email", "type": "str"}
  ],
  "methods": [
    {
      "name": "to_dict",
      "docstring": "Convert to dictionary",
      "returns": "dict"
    }
  ]
}

# 생성된 문서
### User

User entity

**Attributes**:
- `id`: int
- `name`: str
- `email`: str

**Methods**:
- `to_dict() -> dict`: Convert to dictionary
```

### Go

```
GO AST NODES:
├─ File
│   ├─ Package: *Ident
│   ├─ Imports: []*ImportSpec
│   │
│   ├─ TypeSpec
│   │   ├─ Name: *Ident
│   │   └─ Type: Expr
│   │
│   ├─ FuncDecl
│   │   ├─ Name: *Ident
│   │   ├─ Recv: *FieldList (receiver)
│   │   ├─ Type: *FuncType
│   │   └─ Body: *BlockStmt
│   │
│   └─ GenDecl (import, const, type, var)
```

#### 추출 예시

```go
// 입력 코드
type User struct {
    ID    int    `json:"id"`
    Name  string `json:"name"`
    Email string `json:"email"`
}

func (u *User) Validate() error {
    if u.Email == "" {
        return errors.New("email is required")
    }
    return nil
}

// AST 분석 결과
{
  "type": "TypeSpec",
  "name": "User",
  "kind": "struct",
  "fields": [
    {
      "name": "ID",
      "type": "int",
      "tag": "json:\"id\""
    },
    {
      "name": "Name",
      "type": "string",
      "tag": "json:\"name\""
    },
    {
      "name": "Email",
      "type": "string",
      "tag": "json:\"email\""
    }
  ],
  "methods": [
    {
      "name": "Validate",
      "receiver": "*User",
      "returns": ["error"]
    }
  ]
}

// 생성된 문서
### User

**Fields**:
- `ID`: int (json:"id")
- `Name`: string (json:"name")
- `Email`: string (json:"email")

**Methods**:
- `(u *User) Validate() error`: Validates user data
```

---

## 의존성 분석

### Import 그래프

```
DEPENDENCY GRAPH:
┌─────────────────────────────────────────────────────────┐
│                   Root Module                            │
│               (app.module.ts)                            │
└───────────────┬───────────────┬─────────────────────────┘
                │               │
        ┌───────┴──────┐    ┌───┴────────┐
        │ AuthModule   │    │ UserModule │
        └──────┬───────┘    └────┬───────┘
               │                 │
      ┌────────┴────────┐    ┌───┴────────────┐
      │ JwtModule       │    │ TypeOrmModule  │
      │ PassportModule  │    │ RedisModule    │
      └─────────────────┘    └────────────────┘
```

### 의존성 추출 알고리즘

```typescript
interface DependencyGraph {
  nodes: Map<string, ModuleNode>;
  edges: Set<[string, string]>;
}

interface ModuleNode {
  path: string;
  name: string;
  imports: string[];
  exports: string[];
  declarations: string[];
}

function analyzeDependencies(rootPath: string): DependencyGraph {
  const graph: DependencyGraph = {
    nodes: new Map(),
    edges: new Set(),
  };

  // 1. 모든 파일 스캔
  const files = glob('**/*.ts', { cwd: rootPath });

  for (const file of files) {
    // 2. AST 파싱
    const ast = parseTypeScript(file);

    // 3. Import 추출
    const imports = extractImports(ast);

    // 4. 노드 추가
    graph.nodes.set(file, {
      path: file,
      name: extractModuleName(ast),
      imports,
      exports: extractExports(ast),
      declarations: extractDeclarations(ast),
    });

    // 5. 엣지 추가
    for (const imp of imports) {
      graph.edges.add([file, imp]);
    }
  }

  return graph;
}
```

### 순환 의존성 감지

```typescript
function detectCircularDependencies(
  graph: DependencyGraph
): string[][] {
  const cycles: string[][] = [];
  const visited = new Set<string>();
  const recursionStack = new Set<string>();

  function dfs(node: string, path: string[]): void {
    visited.add(node);
    recursionStack.add(node);
    path.push(node);

    const moduleNode = graph.nodes.get(node);
    if (!moduleNode) return;

    for (const dependency of moduleNode.imports) {
      if (!visited.has(dependency)) {
        dfs(dependency, [...path]);
      } else if (recursionStack.has(dependency)) {
        // 순환 의존성 발견
        const cycleStart = path.indexOf(dependency);
        cycles.push([...path.slice(cycleStart), dependency]);
      }
    }

    recursionStack.delete(node);
  }

  for (const node of graph.nodes.keys()) {
    if (!visited.has(node)) {
      dfs(node, []);
    }
  }

  return cycles;
}
```

---

## 자동 문서 추출

### JSDoc/TSDoc 파싱

```typescript
/**
 * User service for managing user operations
 *
 * @example
 * ```typescript
 * const userService = new UserService();
 * const user = await userService.findById(1);
 * ```
 */
export class UserService {
  /**
   * Find a user by ID
   *
   * @param id - User ID
   * @returns User entity or null
   * @throws {NotFoundException} If user not found
   */
  async findById(id: number): Promise<User | null> {
    // ...
  }
}

// 추출된 문서
{
  "class": {
    "name": "UserService",
    "description": "User service for managing user operations",
    "example": "const userService = new UserService();\nconst user = await userService.findById(1);"
  },
  "methods": [
    {
      "name": "findById",
      "description": "Find a user by ID",
      "params": [
        {
          "name": "id",
          "type": "number",
          "description": "User ID"
        }
      ],
      "returns": {
        "type": "Promise<User | null>",
        "description": "User entity or null"
      },
      "throws": [
        {
          "type": "NotFoundException",
          "description": "If user not found"
        }
      ]
    }
  ]
}
```

### Python Docstring 파싱

```python
class UserService:
    """User service for managing user operations

    This service handles all user-related operations including
    CRUD operations and authentication.

    Attributes:
        repository: User repository instance
        cache: Redis cache instance

    Example:
        >>> service = UserService(repo, cache)
        >>> user = service.find_by_id(1)
    """

    def find_by_id(self, user_id: int) -> Optional[User]:
        """Find a user by ID

        Args:
            user_id: The ID of the user to find

        Returns:
            User entity if found, None otherwise

        Raises:
            ValueError: If user_id is invalid
        """
        pass

# 추출된 문서
{
  "class": {
    "name": "UserService",
    "description": "User service for managing user operations",
    "attributes": [
      {"name": "repository", "description": "User repository instance"},
      {"name": "cache", "description": "Redis cache instance"}
    ],
    "example": "service = UserService(repo, cache)\nuser = service.find_by_id(1)"
  },
  "methods": [
    {
      "name": "find_by_id",
      "description": "Find a user by ID",
      "params": [
        {
          "name": "user_id",
          "type": "int",
          "description": "The ID of the user to find"
        }
      ],
      "returns": {
        "type": "Optional[User]",
        "description": "User entity if found, None otherwise"
      },
      "raises": [
        {
          "type": "ValueError",
          "description": "If user_id is invalid"
        }
      ]
    }
  ]
}
```

---

## API 문서 자동 생성

### OpenAPI 생성

```typescript
// NestJS 컨트롤러
@Controller('users')
@ApiTags('users')
export class UserController {
  @Get(':id')
  @ApiOperation({ summary: 'Get user by ID' })
  @ApiParam({ name: 'id', type: 'number' })
  @ApiResponse({ status: 200, type: User })
  @ApiResponse({ status: 404, description: 'User not found' })
  async getUser(@Param('id') id: number): Promise<User> {
    return this.userService.findById(id);
  }
}

// 생성된 OpenAPI 스펙
{
  "paths": {
    "/users/{id}": {
      "get": {
        "tags": ["users"],
        "summary": "Get user by ID",
        "parameters": [
          {
            "name": "id",
            "in": "path",
            "required": true,
            "schema": { "type": "number" }
          }
        ],
        "responses": {
          "200": {
            "description": "User entity",
            "content": {
              "application/json": {
                "schema": { "$ref": "#/components/schemas/User" }
              }
            }
          },
          "404": {
            "description": "User not found"
          }
        }
      }
    }
  }
}
```

### GraphQL Schema 생성

```typescript
// GraphQL Resolver
@Resolver(() => User)
export class UserResolver {
  @Query(() => User, { nullable: true })
  async user(@Args('id') id: number): Promise<User | null> {
    return this.userService.findById(id);
  }

  @Mutation(() => User)
  async createUser(@Args('input') input: CreateUserInput): Promise<User> {
    return this.userService.create(input);
  }
}

// 생성된 Schema
type Query {
  user(id: Int!): User
}

type Mutation {
  createUser(input: CreateUserInput!): User!
}

type User {
  id: Int!
  name: String!
  email: String!
}

input CreateUserInput {
  name: String!
  email: String!
}
```

---

## 다이어그램 자동 생성

### 클래스 다이어그램

```typescript
// 코드
class User {
  id: number;
  name: string;
}

class UserService {
  private repository: UserRepository;

  findById(id: number): Promise<User> {}
}

class UserRepository {
  save(user: User): Promise<User> {}
}

// 생성된 Mermaid
classDiagram
    class User {
        +number id
        +string name
    }
    class UserService {
        -UserRepository repository
        +findById(id: number) Promise~User~
    }
    class UserRepository {
        +save(user: User) Promise~User~
    }
    UserService --> UserRepository
    UserService ..> User
    UserRepository ..> User
```

### 시퀀스 다이어그램

```typescript
// HTTP 요청 플로우 분석
@Controller('users')
export class UserController {
  @Get(':id')
  async getUser(@Param('id') id: number) {
    const user = await this.userService.findById(id);
    if (!user) throw new NotFoundException();
    return user;
  }
}

// 생성된 Mermaid
sequenceDiagram
    participant Client
    participant UserController
    participant UserService
    participant Database

    Client->>UserController: GET /users/:id
    UserController->>UserService: findById(id)
    UserService->>Database: SELECT query
    Database-->>UserService: User data
    alt User found
        UserService-->>UserController: User
        UserController-->>Client: 200 OK (User)
    else User not found
        UserService-->>UserController: null
        UserController-->>Client: 404 Not Found
    end
```

---

## 사용 예시 추출

### 테스트에서 예시 추출

```typescript
// 테스트 코드
describe('UserService', () => {
  it('should find user by id', async () => {
    // Arrange
    const userId = 1;
    const expectedUser = { id: 1, name: 'John' };

    // Act
    const user = await service.findById(userId);

    // Assert
    expect(user).toEqual(expectedUser);
  });
});

// 생성된 예시
### Example: Find user by ID

\`\`\`typescript
const userService = new UserService();
const user = await userService.findById(1);

console.log(user);
// Output: { id: 1, name: 'John' }
\`\`\`
```

---

## 변경 추적

### Git 정보 분석

```typescript
interface FileHistory {
  file: string;
  commits: {
    hash: string;
    author: string;
    date: Date;
    message: string;
  }[];
}

async function analyzeFileHistory(filePath: string): Promise<FileHistory> {
  // Git 로그 조회 (Bash 도구 사용)
  const result = await bash(`git log --follow --format=%H|%an|%ad|%s -- ${filePath}`);

  const commits = result.split('\n').map(line => {
    const [hash, author, date, message] = line.split('|');
    return { hash, author, date: new Date(date), message };
  });

  return { file: filePath, commits };
}
```

### 변경 이력 문서화

```markdown
## Recent Changes

### 2024-01-15: User authentication refactor
**Author**: John Doe
**Commit**: abc123

- Migrated from session-based to JWT authentication
- Added refresh token mechanism
- Updated all user endpoints

**Files changed**: 15
**Lines added**: +345
**Lines removed**: -123

[View diff](https://github.com/repo/commit/abc123)
```

---

[CLAUDE.md](../CLAUDE.md) | [template-library.md](template-library.md) | [progressive-disclosure.md](progressive-disclosure.md)
